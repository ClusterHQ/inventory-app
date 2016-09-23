#!/bin/sh

cd -P -- "$(dirname -- "$0")" && pwd -P

### This script will build and run the dealership import script
tag='clusterhq/inventory-app:dealerimport-0.1'

docker build --file Dockerfile --no-cache --tag $tag .

docker run -e DATABASE_HOST=db --net=inventory_net -dit $tag
