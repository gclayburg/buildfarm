#!/bin/bash
HOMEDIR=$(dirname $0)
cd $HOMEDIR
ssh-keygen -t rsa -b 4096 -C jenkins-master -f jenkins-master-key -N ""
cp jenkins-master-key ../jenkins-data/jenkins-master-key
cp jenkins-master-key.pub ../jenkins-data/jenkins-master-key.pub

cat jenkins-master-key.pub >> authorized_keys

#insert my own keys everywhere to ease manual troubleshooting
[ -r ~/.ssh/id_dsa.pub ] && cat ~/.ssh/id_dsa.pub >> authorized_keys
[ -r ~/.ssh/id_ecdsa.pub ] && cat ~/.ssh/id_ecdsa.pub >> authorized_keys
[ -r ~/.ssh/id_ed25519.pub ] && cat ~/.ssh/id_ed25519.pub >> authorized_keys
[ -r ~/.ssh/id_rsa.pub ] && cat ~/.ssh/id_rsa.pub >> authorized_keys
[ -r ~/.ssh/authorized_keys ] && cat ~/.ssh/authorized_keys >> authorized_keys

cp authorized_keys ../ssh-data/
cp authorized_keys ../jslave-data/

