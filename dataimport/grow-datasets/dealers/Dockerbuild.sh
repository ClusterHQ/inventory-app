#!/bin/sh

url=$1

if [ -z "$url" ]; then
    echo "URL was unset, exiting. Usage: Dockerbuild.sh <http://<frontend-url>:<port>"
    exit 1
fi 

cd -P -- "$(dirname -- "$0")" && pwd -P

### This script will build and run the dealership import script
tag='clusterhq/add-dealers-loop'

docker build --file Dockerfile --no-cache --tag $tag .

docker run -dti $tag "${url}"
