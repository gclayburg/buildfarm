FROM buildfarm_jslavejava8
MAINTAINER Gary Clayburg

# create git user
RUN useradd -m -d /home/git -s /bin/bash git &&\
    echo "git:git" | chpasswd

