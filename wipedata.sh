#!/bin/bash
export DOCKERGID=NA
export BUILDFARM_HOSTNAME=NA
docker-compose stop
docker-compose rm "$@" jenkinsmaster jenkinsnginx
docker-compose rm -v "$@" jenkinsdata
#docker-compose rm -v "$@" jslavedata
#docker-compose rm -v "$@" sshdata
docker rm -v $(docker ps --filter status=exited -q 2>/dev/null)
docker rmi $(docker images -q --filter="dangling=true")
