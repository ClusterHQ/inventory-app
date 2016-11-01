#!/bin/bash

BRANCH=$1
DIR=$2

git clone -b $BRANCH https://$GITUSER:$GITTOKEN@github.com/ClusterHQ/inventory-app $DIR