#!/bin/bash
#DOCKERGID is needed for "docker-compose build" to make sure jenkins can run docker commands inside container
# We are assuming that the group id for the docker user on the host that runs "docker-compose build" is the same as the host that runs the containers
export DOCKERGID=$(id -g docker)

#BUILDFARM_HOST is used to configure Jenkins automatic builds on git push.  See ./ssh-data/post-receive.
export BUILDFARM_HOSTNAME="$(hostname)"

cd $(dirname $0)

#generate ssh keys for all servers, if we don't have a jenkins master key already, i.e. the first time this is run
if [[ ! -f keys/jenkins-master-key ]]; then
  if ! keys/genkey.sh ; then 
    echo "ERROR generating ssh keys.  Fix this manually before starting buildfarm." 
    exit 1
  fi
  echo "new ssh key generated for jenkins master"
fi
docker-compose stop && docker-compose build && docker-compose up -d jenkinsdata jslavedata jenkinsmaster jenkinsnginx sshcoderepo && docker-compose logs
