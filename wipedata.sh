#!/bin/bash
docker-compose stop
docker-compose rm jenkinsmaster jenkinsnginx
#docker-compose rm -v jenkinsdata
docker-compose rm -v jslavedata
docker rmi $(docker images -q --filter="dangling=true")
