FROM buildfarm_sshcoderepo
MAINTAINER Gary Clayburg

USER root
COPY .ssh /home/git/.ssh

RUN cd /home/git && git init --bare coderepo.git && curl -L http://bit.ly/universaldotfiles | bash
COPY post-receive /home/git/coderepo.git/hooks/post-receive.tmp

ARG BUILDFARM_HOST=overridemeifyouwanttotriggerjenkinsbuildongitpush

RUN cat /home/git/coderepo.git/hooks/post-receive.tmp | \
        sed -e "s/BUILDFARMHOST/${BUILDFARM_HOST}/g" \
        > /home/git/coderepo.git/hooks/post-receive && \
    rm /home/git/coderepo.git/hooks/post-receive.tmp && \
    chmod 600 /home/git/.ssh/authorized_keys &&\
    chown -R git:git /home/git &&\
    chmod 755 /home/git/coderepo.git/hooks/post-receive 

VOLUME ["/home/git"]

USER git
CMD ["echo", "Data container for git"]
