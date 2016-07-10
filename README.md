
This creates a Continuous Integration build farm.

### Pre-requirements
- [Docker Engine]
- [Docker Compose] 
- [Linux]  I use CoreOS for the small footprint, but any recent Linux that supports Docker should work fine

This project was tested with Docker version 1.10 and docker-compose version 1.6.2.

### Background

Setting up a build with Jenkins and all the plugins, build jobs and dependencies can be quite an undertaking.  Once it is setup though, it just works.

### Running

```sh
$ git clone git@github.com:gclayburg/buildfarm.git
$ cd buildfarm
$ ./bounce.sh
```

# What does this do?
This will take a while the first time this is executed.  While we are waiting, lets dig into it.

bounce.sh
```sh
#!/bin/bash
docker-compose stop && docker-compose build && docker-compose up -d jenkinsdata jslavedata jenkinsmaster jenkinsnginx && docker-compose logs
```

`docker-compose stop` does nothing yet since there are no docker images running yet in this build farm.  You can see this for yourself with a plain docker command in a new terminal session:

```sh
$ docker ps
```

`docker-compose build` is going to build a bunch of docker images for us.  The rules for building these come from the `docker-compose.yml` file and all the sub-directories of this project.  If you look closely at the output of bounce.sh you'll see lines that look like this - along with lots of verbose output:

```sh
Building jenkinsdata
...
Building jslavejava8
...
Building jslavedata
...
Building jslavenode
...
Building jenkinsmaster
...
Building jenkinsnginx
...
```
This are the 6 docker images that docker-compose built for us.

`docker-compose up -d jenkinsdata jslavedata jenkinsmaster jenkinsnginx`
This starts 4 named containers detached from the terminal.  Note, we are not starting containers from all of the images that we build. We are going to rely on Jenkins and the [docker-plugin] to start our build slave container


Lets break down the first 2 images in the docker-compose-yml file:

```sh
jenkinsdata:
 build: jenkins-data
jenkinsmaster:
 build: jenkins-master
 volumes_from:
  - jenkinsdata
 ports:
  - "50000:50000"
```
The `jenkinsmaster` image is specified from the Dockerfile in the jenkins-master/ directory.  Likewise, `jenkinsdata` comes from jenkins-data/.  `jenkinsmaster` is a customized version of the [official Jenkins docker image]. Our `jenkinsmaster` pre-loads a bunch of Jenkins plugins to support common things like git version control, [pipeline builds], and docker slaves.  You should be able to get running quickly with Jenkins, docker and pipeline builds from a git repository without needing to figure out which Jenkins plugins to install.  This `jenkinsmaster` image takes care of that for you.

`jenkinsdata` is a Docker [data volume container] that is used by `jenkinsmaster` We are using it to preserve the [JENKINS_HOME] directory between Jenkins server restarts.  Our [JENKINS_HOME] at /var/jenkins_home is the only persistent directory in the `jenkinsmaster` image.  

# Jenkins Slaves
We are using the Jenkins [docker-plugin] for launching Jenkins slaves and the Jenkins pipeline style builds.  The way this works is that the build pipeline script will reference a node with a node label.  At build time, Jenkins will match this label with a container label configured with the [docker-plugin]

The bottom 3 images we build look like this:
```sh
jslavejava8:
 build: jslave-java8
jslavenode:
 build: jslave-nodejs445
 volumes_from:
  - jslavedata
jslavedata:
 build: jslave-data
```
`jslavenode` is our main Jenkins slave container.  It has Java, Maven, and nodeJS installed and executes sshd on startup.  [docker-plugin] is responsible for installing and starting the Jenkins slave agent at build time.  

# Configuration

Ok, back to running this thing.  Hopefully if you have read this far, the bouce.sh script should be about done.  Lets just blindly assume for now that there were no erors.  You should see log output from our Jenkins master server in your terminal.  Jenkins is up when you see this in the log 
`jenkinsmaster_1 | INFO: Jenkins is fully up and running`

Open up another terminal window and run these commands:
```sh
$ cd buildfarm
$ docker-compose ps
          Name                         Command               State                  Ports                
--------------------------------------------------------------------------------------------------------
buildfarm_jenkinsdata_1     /bin/tini -- /usr/local/bi ...   Exit 0                                      
buildfarm_jenkinsmaster_1   /bin/tini -- /usr/local/bi ...   Up       0.0.0.0:50000->50000/tcp, 8080/tcp 
buildfarm_jenkinsnginx_1    nginx                            Up       0.0.0.0:80->80/tcp                 
buildfarm_jslavedata_1      echo Data container for Je ...   Exit 0                                      
```

You can see that we have 2 containers running, and 2 that have exited.  The 2 data containers had nothing to do after they setup their volumes, so they exited immediately.  This is normal. So we are left with 2 running containers named `
`buildfarm_jenkinsmaster_1` and `buildfarm_jenkinsnginx_1`.  `docker-compose` created our container name automatically for us based on the image name and our base directory - buildfarm in our case.  

I haven't mentioned the `jenkinsnginx` image yet.  All we are using it for is a reverse proxy for `jenkinsmaster`.  `jenkinsnginx` listens on port 80 and forwards everything to our jenkinsmaster, which listens on port 8080.  You can also see in the port mapping section above that port 8080 exposed on jenkinsmaster is not mapped to a local port, so our browser can only access Jenkins on port 80.  

Lets get to configuring Jenkins and our build job.  Open a browser to port 80 on the host where buildfarm is running.  You should see this:

![new jobs](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/create-new-jobs.png)

Navigate to Manage Jenkins->Configuration. Scroll to the bottom of the page to the Cloud section. Click Add a new cloud->Docker

![add-new-cloud](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/add-new-cloud.png)

Fill in the Name and Docker URL fields.  This is telling the docker-plugin to lauch our slave by first connecting to our unsecured docker daemon listening on port 2375.  (Your docker daemon must be listening on this port)  Since ours is unsecured, we leave credentials empty.  

![cloud-name-url](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/cloud-name-url.png)

Make sure you use the Test Connection button to verify that Jenkins can communicate to the Docker daemon.

Click on Add Docker Template->Docker Template

This is where we tell the docker-plugin what docker images we should use for performing builds.

Fill in the fields for `Docker Image`, `Labels`, and `Launch method`
![new jobs](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/docker-template.png)

The last thing we need to do is add credentials for the docker-plugin to make the ssh connection to our slave container.  Click the add button to add a Jenkins credential.  The username is jenkins and the password is jenkins.

![jenkins-jenkins](http://raw.githubusercontent.com/gclayburg/buildfarm/master/screenshots/jenkins-jenkins.png)
Click Add and then Save.  We are now ready to create our pipeline build job.



[Linux]: <http://www.ubuntu.com>
[Docker Engine]: <https://docs.docker.com/engine/understanding-docker/>
[Docker Compose]: <https://docs.docker.com/compose/install/>
[official Jenkins docker image]: <https://hub.docker.com/_/jenkins/>
[pipeline builds]: <https://jenkins.io/doc/pipeline/>
[Data Volume Container]: <https://docs.docker.com/v1.10/engine/userguide/containers/dockervolumes/#creating-and-mounting-a-data-volume-container>
[JENKINS_HOME]: <https://wiki.jenkins-ci.org/display/JENKINS/Administering+Jenkins>
[docker-plugin]: <https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin>

