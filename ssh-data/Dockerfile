FROM buildfarm_jslavejava8
MAINTAINER Gary Clayburg

# create git user
RUN useradd -m -d /home/git -s /bin/bash git &&\
    echo "git:git" | chpasswd

USER git
RUN cd /home/git && git init --bare coderepo.git && curl -L http://bit.ly/universaldotfiles | bash
COPY post-receive /home/git/coderepo.git/hooks/post-receive.tmp
ARG BUILDFARM_HOST=overridemeifyouwanttotriggerjenkinsbuildongitpush
RUN cat /home/git/coderepo.git/hooks/post-receive.tmp | sed -e "s/BUILDFARMHOST/${BUILDFARM_HOST}/g" > /home/git/coderepo.git/hooks/post-receive && rm /home/git/coderepo.git/hooks/post-receive.tmp


RUN chown git:git /home/git

RUN mkdir /home/git/.ssh 

RUN chmod 700 /home/git/.ssh
COPY config /home/git/.ssh/config 
COPY authorized_keys /home/git/.ssh/authorized_keys
USER root
RUN chown git:git /home/git/.ssh/*
RUN chmod 600 /home/git/.ssh/authorized_keys

RUN chown git:git /home/git/coderepo.git/hooks/post-receive 
RUN chmod 755 /home/git/coderepo.git/hooks/post-receive 

VOLUME ["/home/git"]

USER git
CMD ["echo", "Data container for git"]
