FROM buildfarm_jslavejava8
MAINTAINER Gary Clayburg

#this will be a jenkins slave with nodejs installed

RUN apt-get update -qq

RUN apt-get install -y curl
RUN cd /tmp && curl -sL https://deb.nodesource.com/setup_4.x | bash && apt-get install -y nodejs  && apt-get install -y build-essential

RUN npm install -g bower gulp

# install maven 
ENV MAVEN_VERSION 3.3.1
RUN cd /usr/local; wget -O - http://mirrors.ibiblio.org/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xvzf -
RUN ln -sv /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn

