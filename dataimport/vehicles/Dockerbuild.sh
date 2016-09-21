#!/bin/sh

cd -P -- "$(dirname -- "$0")" && pwd -P

### This script will build and run the dealership import script
tag='clusterhq/inventory-app:vehicle-0.1'

docker build --file Dockerfile --no-cache --tag $tag .

docker run --net=inventoryapp_default -dit $tag
