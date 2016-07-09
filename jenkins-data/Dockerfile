FROM buildfarm_jenkinsmaster
MAINTAINER Gary Clayburg

USER root
COPY .ssh /var/jenkins_home/.ssh
RUN chmod 700 /var/jenkins_home/.ssh &&\
    chmod 600 /var/jenkins_home/.ssh/id_rsa &&\
    chmod 644 /var/jenkins_home/.ssh/id_rsa.pub &&\
    chown -R jenkins:jenkins /var/jenkins_home/
VOLUME /var/jenkins_home

USER jenkins
CMD ["echo", "Data container for Jenkins at /var/jenkins_home"]
