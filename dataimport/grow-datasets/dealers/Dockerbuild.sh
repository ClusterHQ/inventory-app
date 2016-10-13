#!/bin/sh

cd -P -- "$(dirname -- "$0")" && pwd -P

### This script will build and run the dealership import script
tag='clusterhq/add-dealers-loop'

docker build --file Dockerfile --no-cache --tag $tag .

docker run -dti $tag 'http://ec2-54-237-204-239.compute-1.amazonaws.com:32787'
