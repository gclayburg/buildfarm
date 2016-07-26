# Docker box BuildFarm
This creates a Continuous Integration BuildFarm by fitting together and automating a bunch of common build tools in the Java, JavaScript, Jenkins, and Docker ecosystems.  It was initially created to help with building [JHipster](https://jhipster.github.io/) projects with Jenkins Pipeline builds, but should be usable for building just about anything.

With this BuildFarm you will be able to
- push your project to the BuildFarm git repository, and watch Jenkins build it
- use the Jenkins pipeline build system without needing to deal with initial configuration.  BuildFarm automates that.

This is all done in docker containers and a healthy dose of automation so you gan get running quickly.


# Software Requirements
To use this project, you need to install just a few tools to get the base Docker environment functional.  
- [Docker Engine] version 1.10 or higher.  This must be configured to listen on port 2375, without TLS enabled
- [Docker Compose] version 1.6.2 or higher
- [Linux]  I use CoreOS for the small footprint, but any recent Linux that supports Docker should work fine

All of the other dependencies are specified and downloaded with the docker compose scripts in this project.

# BuildFarm quickstart
Open a terminal session to your Linux box with Docker installed.  We will be running all of the BuildFarm components on this one box.
```console
$ git clone git@github.com:gclayburg/buildfarm.git
$ cd buildfarm
$ ./bounce.sh
```

This will start the process of downloading, building and running all of the docker images that we need for BuildFarm.  There are 8 total images here, so this will take a while to finish.  While we are waiting, lets create a new development project that we can build with the BuildFarm once it is ready.  We will use the [JHipster](https://jhipster.github.io/) to create our project.  If you have not setup your system for JHipster, [follow those instructions first].  You could choose to create your development project on the same Linux box where you are running BuildFarm, but that isn't necessary.  It might be simpler for you to create the JHipster project on a laptop and run BuildFarm on a separate Linux server.

In a new terminal session on your development workstation, type:
```console
$ mkdir jhip-maven-mysql
$ cd jhip-maven-mysql
$ yo jhipster
```
From here, you can follow the jhipster instructions to select what kind or project to create.  For this quickstart, I chose to create a monolithic application using Maven, MySQL, and H2 in-memory database for development.  Once JHipster has created your application, you can create a new git repository for it and add our new project like this:

```console
$ git init
Initialized empty Git repository in /home/gclaybur/dev/jhip-maven-mysql/.git/
$ git add .
$ git commit -m "First commit"
$ git remote add origin ssh://git@jefferson:2233/home/git/coderepo.git
$ git remote -v
origin	ssh://git@jefferson:2233/home/git/coderepo.git (fetch)
origin	ssh://git@jefferson:2233/home/git/coderepo.git (push)
```
Here, I am using the hostname `jefferson` for the git remote repository.  That is the name of my Linux server where BuildBarm is installed.  Make sure to substitute the hostname of your server.  The port number will still be 2233.  That number is hardcoded in the sshcoderepo docker image.  More on these images later.

# Build a pre-generated JHipster project

If you would rather skip the process of creating your own application to build, you can clone this project from github instead:
```console
$ git clone https://github.com/gclayburg/hello-jhipster
$ cd hello-jhipster
$ git remote add buildfarm ssh://git@jefferson:2233/home/git/coderepo.git
$ git remote -v
buildfarm	ssh://git@jefferson:2233/home/git/coderepo.git (fetch)
buildfarm	ssh://git@jefferson:2233/home/git/coderepo.git (push)
origin	https://github.com/gclayburg/hello-jhipster (fetch)
origin	https://github.com/gclayburg/hello-jhipster (push)

```
This hello-jhipster was also largely generated from JHipster.  It is a Monolithic application that uses the Maven project model, and a MongoDB database.  The pom.xml file is slightly modified from the default to allow for parallel testing with the `prodtest` profile.

If you use this project, just remember to push to `buildfarm` and not `origin` to trigger Jenkins builds.  

# Push and Build

We are almost ready to push our code to our BuildFarm.  When the BuildFarm is ready, you will see standard Jenkins log messages back in our terminal window where bounce.sh is running.  Look for a line that looks like this:
```
jenkinsmaster_1 | INFO: Jenkins is fully up and running
```
Once this message appears, we are ready to push our code to our remote repository.  
```console
$ git push origin master
Warning: Permanently added '[jefferson]:2233,[192.168.1.137]:2233' (RSA) to the list of known hosts.
Counting objects: 3044, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2985/2985), done.
Writing objects: 100% (3044/3044), 3.94 MiB | 3.19 MiB/s, done.
Total 3044 (delta 626), reused 0 (delta 0)
remote:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
remote:                                  Dload  Upload   Total   Spent    Left  Speed
remote: 100   108  100   108    0     0    542      0 --:--:-- --:--:-- --:--:--   548
remote: No git jobs found
remote: No Git consumers using SCM API plugin for: ssh://git@jefferson:2233/home/git/coderepo.git
To ssh://git@jefferson:2233/home/git/coderepo.git
 * [new branch]      master -> master
```

One thing I'll point out here is the messages printed here from the remote repository.  `No git jobs found` means that the Jenkins git plugin did not find a matching job to build.  This is normal for the first git push of our project.  We need to use the Jenkins UI to manually trigger our first build.  So, open a browser to the Jenkins UI. It should look like this:

![2 new jobs](/screenshots/jenkins-2-initial-jobs.png?raw=true)

Click the build button for the `buildfarm1` job.  It should complete quickly with an error.  The console output of this build should end with something like this:
```
ERROR: /var/jenkins_home/workspace/buildfarm1@script/Jenkinsfile not found
Finished: FAILURE
```
This build job in Jenkins is preconfigured to expect a `Jenkinsfile` in the root of our project.  We need to add this to tell Jenkins exactly what steps are needed to build, test, package and run our application.  Copy the `Jenkinsfile` from the root of this project into your development directory and commit and push your changes:
```console
$ cp ../buildfarm/Jenkinsfile .
$ git add Jenkinsfile && git commit -m "Initial Jenkinsfile" && git push origin master
[master 3209e98] Initial Jenkinsfile
 1 file changed, 107 insertions(+)
 create mode 100644 Jenkinsfile
Warning: Permanently added '[jefferson]:2233,[192.168.1.137]:2233' (RSA) to the list of known hosts.
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 1.73 KiB, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
remote:                                  Dload  Upload   Total   Spent    Left  Speed
remote: 100   122  100   122    0     0   4130      0 --:--:-- --:--:-- --:--:--  4206
remote: Scheduled polling of buildfarm1
remote: No Git consumers using SCM API plugin for: ssh://git@jefferson:2233/home/git/coderepo.git
To ssh://git@jefferson:2233/home/git/coderepo.git
   1d3ddad..3209e98  master -> master
```
Note the message here `remote: Scheduled polling of buildfarm1`.  This means our git push has triggered a build of our buildfarm1 job in Jenkins.  For our purposes here, the other messages can be ignored.

So with any luck your project is now building on Jenkins.  The Jenkinsfile we are using will build a production war file, run all the tests, and create and run a docker image of this app.  When the build finishes without errors you will find it running at on port 8080 on your Linux docker box - http://jefferson:8080 in my case.  The build runs the application based on your docker-compose definitions at `src/main/docker/app.yml`.  Now you can manually inspect the production app.

Of course, you will probably want to customize what your build does.  You might want to run some of the tests in parallel or deploy the app to a different server - or maybe somewhere in the cloud.  Who knows, maybe you need some further downstream integration testing against the running server.

# BuildFarm behind the scenes
Under the covers the BuildFarm will automatically:
- run Jenkins in a docker container
- configure Jenkins with plugins preconfigured for common things like git source code management, Jenkins Pipeline jobs, and the docker plugin
- create a persistent docker volume for storing your Jenkins build jobs and history (JENKINS_HOME)
- configure Jenkins docker plugin to manage a Jenkins slave server
- setup a docker container running the build slave that will be able to
  - build your project with Java,Maven,NodeJS
  - create a docker image of your project
  - run your project from its docker-compose yaml definition
  - use the created docker volume to cache things like the Maven repository and node dependencies
- configure a ssh server for use as a git repository, running in a docker container
- setup a bare git repository on the ssh server
- setup git post-receive hook to trigger Jenkins build job 
- create a persistent docker volume for storing the git repository data
- generate ssh private key for Jenkins master
- establish ssh trust to Jenkins slave server via authorized_keys
- establish ssh trust to ssh coderepo server via authorized_keys
- generate Jenkins credentials to use these generated keys.  Your build jobs just select the key they need.
- populate Jenkins with a build job to automatically build code from the git code repository
- configure an nginx server to act as a reverse proxy for Jenkins UI

This is all done on a single Linux box running docker.  Since all of this is automated with Docker, BuildFarm is very quick to setup and very portable.

[Docker Images](DockerImages.md)


# Credits
- [Riot Games Engineering](https://github.com/maxfields2000/dockerjenkins_tutorial)  A great tutorial and practical advice for running Jenkins and Docker together.  






[Linux]: <http://www.ubuntu.com>
[Docker Engine]: <https://docs.docker.com/engine/understanding-docker/>
[Docker Compose]: <https://docs.docker.com/compose/install/>
[jhipster]: <https://jhipster.github.io/>
[follow those instructions first]: <https://jhipster.github.io/creating-an-app/>
