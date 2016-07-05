FROM java:8u91
MAINTAINER Gary Clayburg

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

USER jenkins
RUN mkdir /var/jenkins_home/.ssh 
RUN ls -lrta /var/jenkins_home

RUN chmod 700 /var/jenkins_home/.ssh
COPY config /var/jenkins_home/.ssh/config 
COPY jenkins-master-key /var/jenkins_home/.ssh/id_rsa
COPY jenkins-master-key.pub /var/jenkins_home/.ssh/id_rsa.pub

USER root
RUN chown jenkins:jenkins /var/jenkins_home/.ssh/*
#RUN chmod 600 /var/jenkins_home/.ssh/id_rsa
#RUN chmod 644 /var/jenkins_home/.ssh/id_rsa.pub

USER jenkins
# Jenkins home directory is a volume, so configuration and build history 
# can be persisted and survive image upgrades
VOLUME /var/jenkins_home

# Create the folders and volume mount points
VOLUME ["/var/jenkins_home"]
CMD ["echo", "Data container for Jenkins at /var/jenkins_home"]
