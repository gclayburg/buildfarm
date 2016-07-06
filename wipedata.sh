#!/bin/bash
export DOCKERGID=pleasedontaskmeareyousurethankyouverymuch
docker-compose stop
docker-compose rm jenkinsmaster jenkinsnginx
docker-compose rm -v jenkinsdata
docker-compose rm -v jslavedata
docker-compose rm -v sshdata
docker rmi $(docker images -q --filter="dangling=true")
