#!/bin/bash
docker-compose stop && docker-compose build && docker-compose up -d jenkinsdata jslavedata jenkinsmaster jenkinsnginx && docker-compose logs
