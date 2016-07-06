FROM buildfarm_jslavejava8
MAINTAINER Gary Clayburg

RUN chown jenkins:jenkins /home/jenkins

USER jenkins
RUN mkdir /home/jenkins/.ssh 

RUN chmod 700 /home/jenkins/.ssh
COPY config /home/jenkins/.ssh/config 
COPY authorized_keys /home/jenkins/.ssh/authorized_keys
USER root
RUN chown jenkins:jenkins /home/jenkins/.ssh/*
RUN chmod 600 /home/jenkins/.ssh/authorized_keys

VOLUME ["/home/jenkins"]

USER jenkins
CMD ["echo", "Data container for Jenkins"]
