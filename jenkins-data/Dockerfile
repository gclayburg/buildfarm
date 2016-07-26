FROM buildfarm_jenkinsmaster
MAINTAINER Gary Clayburg

USER root
ARG BUILDFARM_HOST=dockerhost
ADD JENKINS_HOME /usr/share/jenkins/ref

# make sure initial buildfarm jobs reference hostname where docker is running - BUILDFARM_HOST is populated in bounce.sh
RUN chmod 700 /usr/share/jenkins/ref/.ssh &&\
    sed -i "s/BUILDFARMHOST/${BUILDFARM_HOST}/g" /usr/share/jenkins/ref/config.xml &&\
    sed -i "s/BUILDFARMHOST/${BUILDFARM_HOST}/g" /usr/share/jenkins/ref/jobs/buildfarm1/config.xml &&\
    chown -R jenkins:jenkins /var/jenkins_home/ &&\
    chown -R jenkins:jenkins /usr/share/jenkins/ref/
VOLUME /var/jenkins_home

USER jenkins
CMD ["echo", "Data container for Jenkins at /var/jenkins_home"]
