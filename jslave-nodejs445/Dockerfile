#FROM registry:5000/dind-jenkins-slave:1.0.1
FROM buildfarm_jslavejava8

#this will be a jenkins slave with nodejs installed

RUN apt-get update -qq

RUN apt-get install -y curl
#RUN cd /tmp && curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - && sudo apt-get install -y nodejs
RUN cd /tmp && curl -sL https://deb.nodesource.com/setup_4.x | bash && apt-get install -y nodejs  && apt-get install -y build-essential

RUN npm install -g bower gulp
RUN su -c 'which bower; which gulp; which node; which npm' jenkins
RUN su -c "echo my path is $PATH" jenkins
#RUN su -c "echo my profile is; cat .profile" jenkins
#RUN su -c '/home/jenkins/.npm-global/bin/bower --version && /home/jenkins/.npm-global/bin/gulp --version' jenkins
RUN su -c 'bower --version && gulp --version' jenkins
#RUN "gulp --version"

# install maven 
ENV MAVEN_VERSION 3.3.1
RUN cd /usr/local; wget -O - http://mirrors.ibiblio.org/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xvzf -
RUN ln -sv /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn



