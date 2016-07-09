FROM buildfarm_jslavenode
MAINTAINER Gary Clayburg

USER root

COPY .ssh /home/jenkins/.ssh
RUN chmod 700 /home/jenkins/.ssh &&\
    chmod 600 /home/jenkins/.ssh/authorized_keys &&\
    chown -R jenkins:jenkins /home/jenkins 

VOLUME ["/home/jenkins"]

USER jenkins
CMD ["echo", "Data container for Jenkins slave"]
