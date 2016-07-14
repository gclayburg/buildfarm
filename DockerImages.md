# How does this work?

bounce.sh
```sh
#!/bin/bash
docker-compose stop && docker-compose -f docker-compose-buildonly.yml build && docker-compose up -d jenkinsdata jslavedata jenkinsmaster jenkinsnginx sshcoderepo && docker-compose logs
```

`docker-compose stop` does nothing yet since there are no docker images running yet in this build farm.  You can see this for yourself with a plain docker command in a new terminal session:

```sh
$ docker ps
```

`docker-compose -f docker-compose-buildonly.yml build` is going to build a bunch of docker images for us.  The rules for building these come from the `docker-compose-buildonly.yml` file and all the sub-directories of this project.  If you look closely at the output of bounce.sh you'll see lines that look like this - along with lots of verbose output:

```sh
Building jenkinsdata
...
Building jslavejava8
...
Building jenkinsnginx
...
```
Altogether, we are building 9 docker images with docker-compose.

`docker-compose up -d jenkinsdata jslavedata jenkinsmaster jenkinsnginx sshcoderepo`
This starts 4 named containers detached from the terminal.  Note, we are not starting containers from all of the images that we build. We are going to rely on Jenkins and the [docker-plugin] to start our build slave container.

### Docker Compose 
Lets break down the first 2 images in the docker-compose-yml file:

```yaml
version: '2'
services:
  jenkinsdata:
   build: 
     context: jenkins-data
     args:
       BUILDFARM_HOST: ${BUILDFARM_HOSTNAME}
  jenkinsmaster:
   build: jenkins-master
   volumes_from:
    - jenkinsdata
   volumes:
    - /var/run/docker.sock:/var/run/docker.sock
   ports:
    - "50000:50000"
   links:
    - sshcoderepo:ssh-coderepo
   environment:
    - "TZ=America/Denver"
```
The `jenkinsmaster` image is specified from the Dockerfile in the `jenkins-master/` directory.  Likewise, `jenkinsdata` comes from `jenkins-data/`.  `jenkinsmaster` is a customized version of the [official Jenkins docker image]. Our `jenkinsmaster` pre-loads a bunch of Jenkins plugins to support common things like git version control, [pipeline builds], and docker slaves.  With the BuildFarm here, you should be able to get running quickly with Jenkins, docker and pipeline builds from a git repository without needing to figure out which Jenkins plugins to install.  This `jenkinsmaster` image takes care of that for you.

`jenkinsdata` is a Docker [data volume container] that is used by `jenkinsmaster` We are using it to preserve the [JENKINS_HOME] directory between Jenkins server restarts.  Our [JENKINS_HOME] at /var/jenkins_home is the only persistent directory in the `jenkinsmaster` image.  

You will also see we are building an image named `jenkinssuper`.  This image is essentially a copy of the [official Jenkins docker image] version 1.651.3 with the `VOLUME` instruction removed from its Dockerfile.  The reason we do this is so that we can add files to this data volume without jumping through hoops.  Things can get a little complicated with you build a docker images derived from a parent that has a VOLUME instruction.  More on this issue [here](https://github.com/jenkinsci/docker/issues/271)

# Jenkins Slaves
We are using the Jenkins [docker-plugin] for launching Jenkins slaves and the Jenkins pipeline style builds.  The way this works is that the Jenkinsfile in our project we are building will reference a node with a node label.  At build time, Jenkins will match this label with a container label configured with the [docker-plugin]. We'll get into configuring that part later.

The docker-compose services we built for our Jenkins slave are these:
```sh
  jslavejava8:
    build: jslave-java8
  jslavenode:
    build: 
      context: jslave-nodejs445
      args:
        DOCKER_GID: ${DOCKERGID}
    depends_on:
      - jslavejava8
  jslavedata:
    build: 
      context: jslave-data
    depends_on:
      - jslavenode
```
`jslavenode` is our main Jenkins slave container.  This is where Jenkins will be doing builds of our Java development project. It has Java, Maven, and node.js installed and executes sshd on startup.  [docker-plugin] is responsible for installing and starting the Jenkins slave agent at build time.  

# SSH code repository server

```yaml
  sshcoderepo:
    build: 
      context: ssh-coderepo
    depends_on:
      - jslavejava8
  sshdata:
    build: 
      context: ssh-data
      args:
        BUILDFARM_HOST: ${BUILDFARM_HOSTNAME}
    depends_on:
      - sshcoderepo
```
These services setup a docker image for hosting our git repository over ssh.  `sshdata` configures the git repository under a volume for the running sshd server from `sshcoderepo`

# Running docker services

Once the services have started, we can take a look at what is running.  Open up another terminal window and run these commands:
```sh
$ docker-compose ps
          Name                         Command               State                  Ports                
--------------------------------------------------------------------------------------------------------
buildfarm_jenkinsdata_1     /bin/tini -- /usr/local/bi ...   Exit 0                                      
buildfarm_jenkinsmaster_1   /bin/tini -- /usr/local/bi ...   Up       0.0.0.0:50000->50000/tcp, 8080/tcp 
buildfarm_jenkinsnginx_1    nginx                            Up       0.0.0.0:80->80/tcp                 
buildfarm_jslavedata_1      echo Data container for Je ...   Exit 0                                      
buildfarm_sshcoderepo_1     /usr/sbin/sshd -D                Up       0.0.0.0:2233->22/tcp               
buildfarm_sshdata_1         echo Data container for git      Exit 0                       
```

You can see that we have 3 containers running, and 3 that have exited.  The 3 data containers had nothing to do after they setup their volumes, so they exited immediately.  This is normal. So we are left with 3 running containers named
`buildfarm_jenkinsmaster_1`,  `buildfarm_jenkinsnginx_1` and `buildfarm_sshcoderepo_1`.  `docker-compose` created our container names automatically for us based on the image name and our base directory - buildfarm in our case.  

I haven't mentioned the `jenkinsnginx` image yet.  This is simply an nginx container configured as a reverse proxy for `jenkinsmaster`.  `jenkinsnginx` listens on port 80 and forwards everything to our jenkinsmaster, which listens on port 8080.  You can also see in the port mapping section above that port 8080 exposed on jenkinsmaster is not mapped to a local port, so our browser can only access Jenkins on port 80.  

### Jenkins build job configuration
Out of the box, BuildFarm will configure Jenkins for you for your first build job using the git repository running on `sshcoderepo`.  The rest of this section goes into how you would configure this manually if you needed to.

Open a browser to port 80 on the host where buildfarm is running.  You should see this:

![new jobs](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/create-new-jobs.png)

Navigate to Manage Jenkins->Configure System. Scroll to the bottom of the page to the Cloud section. Click Add a new cloud->Docker

![add-new-cloud](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/add-new-cloud.png)

Fill in the Name and Docker URL fields.  This is telling the docker-plugin to lauch our slave by first connecting to our unsecured docker daemon listening on port 2375.  (Your docker daemon must be listening on this port)  Since ours is unsecured, we leave credentials empty.  

![cloud-name-url](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/cloud-name-url.png)

Make sure you use the Test Connection button to verify that Jenkins can communicate to the Docker daemon.

Click on Add Docker Template->Docker Template

This is where we tell the docker-plugin what docker images we should use for performing builds.

Fill in the following fields:
```sh
Docker Image: buildfarm_jslavenode
Labels: nodejs4
Launch Method: Docker SSH computer launcher
```

![new jobs](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/docker-template.png)

We also need to fill in the container settings so that the docker plugin will be able to launch our docker image using our already prepared docker volume and the docker socket on our host.  The volume is needed for caching information between builds - things like maven and npm use this volume.  The docker socket is needed for [running docker and docker-compose CLI commands in our slave container](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)  This comes in quite handy for building and running docker images as part of the build of our development projects.  So, fill in these 2 fields under `Container settings...`

```sh
Volumes        /var/run/docker.sock:/var/run/docker.sock
Volumes From   buildfarm_jslavedata_1
```

The last thing we need to do is add credentials for the docker-plugin to make the ssh connection to our slave container.  Click the add button to add a Jenkins credential.  The username is jenkins and the password is jenkins.

![jenkins-jenkins](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/jenkins-jenkins.png)
Click Add and then Save.  We are now ready to create our pipeline build job.

You could also select the credentials from the dropdown.  BuildFarm created 2 entries here.  Both use the ssh key on the Jenkins master server (~jenkins/.ssh/id_rsa).  One is configured to log into a server with the name jenkins and the other is for the user git.

# Create and run build job

From the Jenkins home page, navigate to Jenkins->New Item.  Select Pipeline and give it a name.  Click OK.  In the bottom of the build configuration page, there is a Pipeline section.  Select Definition: Pipeline script from SCM, SCM: Git.  

# Building a project
Now we need something to build from a git repository.  I have a simple [jhipster] generated project already checked into github that you can use.  Enter this for Repository URL: `https://github.com/gclayburg/hello-jhipster.git` This project is just a simple monolithic JHipster project created with a mongodb backend database and a Jenkinsfile added to it.  This Jenkinsfile groovy script has all of the details for building our project.  It is quite handy to be able to express the build lifecycle in a groovy DSL right along side the code to your project.  Anyway, this project is finally ready to build.  Click the build button in Jenkins.  If everything works right, Jenkins will lauch our build slave image from our docker connection and connect to it with ssh to install and start the Jenkins slave.  It will then start building our project from the instructions in our Jenkinsfile.

# Security Hardening

Obviously, there are several areas in the buildfarm that are insecure. The docker daemon listens on an unsecure port, we don't use SSL, the ssh usernames and passwords are widely known, and Jenkins Global Security is not enabled.  If security is important to you, all of these things can be secured.  The reason they aren't secured out of the box is the classic security/usability tradeoff.  In order to make things secure, there are many hoops to jump through.  The goal here is to minimize the number of hoops to get up and running. Security can be added in later.

[official Jenkins docker image]: <https://hub.docker.com/_/jenkins/>
[pipeline builds]: <https://jenkins.io/doc/pipeline/>
[Data Volume Container]: <https://docs.docker.com/v1.10/engine/userguide/containers/dockervolumes/#creating-and-mounting-a-data-volume-container>
[JENKINS_HOME]: <https://wiki.jenkins-ci.org/display/JENKINS/Administering+Jenkins>
[docker-plugin]: <https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin>


