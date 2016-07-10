FROM buildfarm_jslavejava8
MAINTAINER Gary Clayburg

#this will be a jenkins slave with nodejs installed

RUN apt-get update -qq

RUN apt-get install -y curl
RUN cd /tmp && curl -sL https://deb.nodesource.com/setup_4.x | bash && apt-get install -y nodejs  && apt-get install -y build-essential

RUN npm install -g bower gulp
RUN npm install -g npm

# install maven 
ENV MAVEN_VERSION 3.3.9
RUN cd /usr/local; wget -O - http://mirrors.ibiblio.org/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xvzf -
RUN ln -sv /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn

#install specific docker version to match docker version supplied by coreos.  This is to avoid issues with the docker daemon running on coreos and the docker client bundled inside this docker image
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && mkdir -p /etc/apt/sources.list.d && echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list && apt-get update && apt-get install -y -q docker-engine=1.10.3-0~trusty
    
#install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod 755 /usr/local/bin/docker-compose

# add jenkins to docker group which was created by docker install above (gid=999)
# add jenkins user to docker group that coreos uses (gid=233) 
# this allows the jenkins user to use the bind mount /var/run/docker.sock when this container is being run on coreos
#RUN usermod -G docker jenkins && \
#    groupadd -g 233 docker2 && \
#    usermod -G docker2 jenkins

ARG DOCKER_GID=233
RUN usermod -G docker jenkins && groupadd -g ${DOCKER_GID} docker2 && usermod -G docker2 jenkins



