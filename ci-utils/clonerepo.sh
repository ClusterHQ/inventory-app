#!/bin/bash

BRANCH=$1
DIR=$2

# Remove the app in the same workspace to avoid reusing packages, node modules etc.
rm -rf $DIR

if [ -e "clonerepo.sh" ]; then
    echo "File exists"
else 
   wget https://s3-eu-west-1.amazonaws.com/clusterhq/flockerhub-client/clonerepo.sh
   sudo chmod +x clonerepo.sh
fi 

source ~/.bashrc
git clone -b $BRANCH https://$GITUSER:$GITTOKEN@github.com/ClusterHQ/inventory-app $DIR