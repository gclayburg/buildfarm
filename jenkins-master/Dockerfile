FROM jenkins:1.651.3
MAINTAINER Gary Clayburg

# Prep Jenkins Directories
USER root
RUN mkdir /var/cache/jenkins
RUN chown -R jenkins:jenkins /var/cache/jenkins

ARG DOCKER_GID=233
RUN apt-get update -qq && apt-get install -y apt-transport-https
#install specific docker version to match docker version supplied by coreos.  This is to avoid issues with the docker daemon running on coreos and the docker client bundled inside this docker image
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D &&\
    mkdir -p /etc/apt/sources.list.d &&\
    echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list &&\
    apt-get update &&\
    apt-get install -y -q \
                    docker-engine=1.10.3-0~trusty &&\
    #install docker-compose
    curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose &&\
    chmod 755 /usr/local/bin/docker-compose &&\
    usermod -G docker jenkins && groupadd -g ${DOCKER_GID} docker2 && usermod -G docker2 jenkins

# add jenkins to docker group which was created by docker install above (gid=999)
# add jenkins user to docker group that coreos uses (gid=233) 
# this allows the jenkins user to use the bind mount /var/run/docker.sock when this container is being run on coreos
#RUN usermod -G docker jenkins && \
#    groupadd -g 233 docker2 && \
#    usermod -G docker2 jenkins

USER jenkins

# Set list of plugins to download / update in plugins.txt like this
# pluginID:version
# credentials:1.18
# maven-plugin:2.7.1
# ...
# NOTE : Just set pluginID to download latest version of plugin.
# NOTE : All plugins need to be listed as there is no transitive dependency resolution.
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy


# Set Defaults
#ENV JAVA_OPTS="-Xmx8192m"
ENV JENKINS_OPTS="--handlerCountStartup=100 --handlerCountMax=300 --webroot=/var/cache/jenkins/war"
