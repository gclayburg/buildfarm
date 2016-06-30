
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

`docker-compose build` is going to build a bunch of docker images for us.  The rules for building these come from the `docker-compose.yml` file and all the sub-directories of this project.  Lets break down the first 2 images in this file:

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
The `jenkinsmaster` image is specified from the Dockerfile in the jenkins-master/ directory.  Likewise, `jenkinsdata` comes from jenkins-data/.  `jenkinsmaster` is a customized version of the [official Jenkins docker image] that pre-loads a bunch of Jenkins plugins to support common things like git version control, [pipeline builds], and docker slaves.

`jenkinsdata` is a Docker [data volume container] that is used by `jenkinsmaster` We are using it to preserve the [JENKINS_HOME] directory between Jenkins server restarts.  Our [JENKINS_HOME] at /var/jenkins_home is the only persistent directory in the `jenkinsmaster` image.  You might want to backup this directory.


[Linux]: <http://www.ubuntu.com>
[Docker Engine]: <https://docs.docker.com/engine/understanding-docker/>
[Docker Compose]: <https://docs.docker.com/compose/install/>
[official Jenkins docker image]: <https://hub.docker.com/_/jenkins/>
[pipeline builds]: <https://jenkins.io/doc/pipeline/>
[Data Volume Container]: <https://docs.docker.com/v1.10/engine/userguide/containers/dockervolumes/#creating-and-mounting-a-data-volume-container>
[JENKINS_HOME]: <https://wiki.jenkins-ci.org/display/JENKINS/Administering+Jenkins>

