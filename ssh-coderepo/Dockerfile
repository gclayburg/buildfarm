FROM buildfarm_jslavejava8
MAINTAINER Gary Clayburg

# create git user
RUN useradd -m -d /home/git -s /bin/sh git &&\
    echo "git:git" | chpasswd

USER git
RUN echo "hi" && cd /home/git && git init --bare coderepo.git && curl -L http://bit.ly/universaldotfiles | bash
COPY post-receive /home/git/coderepo.git/hooks/post-receive
USER root
