#!/bin/bash
#DOCKERGID is needed for "docker-compose build" to make sure jenkins can run docker commands inside container
# We are assuming that the group id for the docker user on the host that runs "docker-compose build" is the same as the host that runs the containers
export DOCKERGID=$(id -g docker)
docker-compose stop && docker-compose build && docker-compose up -d jenkinsdata jslavedata jenkinsmaster jenkinsnginx sshcoderepo && docker-compose logs
