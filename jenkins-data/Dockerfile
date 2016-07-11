FROM buildfarm_jenkinsmaster
MAINTAINER Gary Clayburg

USER root
ARG BUILDFARM_HOST=dockerhost
COPY .ssh /var/jenkins_home/.ssh
ADD JENKINS_HOME /usr/share/jenkins/ref
RUN chmod 700 /var/jenkins_home/.ssh &&\
    chmod 600 /var/jenkins_home/.ssh/id_rsa &&\
    chmod 644 /var/jenkins_home/.ssh/id_rsa.pub &&\
# make sure initial buildfarm jobs reference hostname where docker is running - BUILDFARM_HOST is populated in bounce.sh
    sed -i "s/BUILDFARMHOST/${BUILDFARM_HOST}/g" /usr/share/jenkins/ref/config.xml &&\
    sed -i "s/BUILDFARMHOST/${BUILDFARM_HOST}/g" /usr/share/jenkins/ref/jobs/buildfarm1/config.xml &&\
    chown -R jenkins:jenkins /var/jenkins_home/ &&\
    chown -R jenkins:jenkins /usr/share/jenkins/ref/
VOLUME /var/jenkins_home

USER jenkins
CMD ["echo", "Data container for Jenkins at /var/jenkins_home"]
