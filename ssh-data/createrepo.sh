#!/bin/bash
NEWREPO=$1
cd /home/git && git init --bare $NEWREPO.git
cat post-receive-template | sed -e "s/BUILDFARMHOST/scranton2/g" -e "s/REPONAME/$NEWREPO/g" > ${NEWREPO}.git/hooks/post-receive
chmod 755 ${NEWREPO}.git/hooks/post-receive
