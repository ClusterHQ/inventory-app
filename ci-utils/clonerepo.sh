#!/bin/bash

BRANCH=$1
DIR=$2

# Remove the app in the same workspace to avoid reusing packages, node modules etc.
rm -rf $DIR

source ~/.bashrc
git clone -b $BRANCH https://$GITUSER:$GITTOKEN@github.com/ClusterHQ/inventory-app $DIR