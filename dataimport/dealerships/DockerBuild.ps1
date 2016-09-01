### This script will build and run the dealership import script
$tag = 'clusterhq/inventory-app:dealerimport-0.1'

docker build --file Dockerfile --no-cache --tag $tag $PSScriptRoot

docker run --net=host -dit $tag