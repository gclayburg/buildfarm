#!/bin/bash
ssh-keygen -t rsa -b 4096 -C jenkins-master -f jenkins-master-key -N ""
cp jenkins-master-key ../jenkins-data/jenkins-master-key
cp jenkins-master-key.pub ../jenkins-data/jenkins-master-key.pub

cat jenkins-master-key.pub >> authorized_keys

#insert my own keys everywhere to ease manual troubleshooting
cat ~/.ssh/id_rsa.pub >> authorized_keys
cat ~/.ssh/authorized_keys >> authorized_keys

cp authorized_keys ../ssh-data/
cp authorized_keys ../jslave-data/

