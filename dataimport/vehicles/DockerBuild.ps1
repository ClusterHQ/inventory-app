### This script will build and run the dealership import script
$tag = 'clusterhq/inventory-app:vehicle-0.1'

docker build --file Dockerfile --no-cache --tag $tag $PSScriptRoot

docker run -e DATABASE_HOST=db --net=inventory_net -dit $tag