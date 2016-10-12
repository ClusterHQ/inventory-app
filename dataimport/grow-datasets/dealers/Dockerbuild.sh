#!/bin/sh

cd -P -- "$(dirname -- "$0")" && pwd -P

### This script will build and run the dealership import script
tag='clusterhq/add-dealers-loop'

docker build --file Dockerfile --no-cache --tag $tag .

docker run -dti $tag
