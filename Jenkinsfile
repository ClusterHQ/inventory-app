node ('v8s-dpcli-prov') {

   stage 'Make sure cloud-init done'
   // Cloud-init runs on new jenkins slaves to install dpcli and docker, make sure its done.
   sh "timeout 1080 /bin/bash -c   'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting for boot to finish ...; sleep 10; done'"

   stage 'See cloud-init log'
   // In case of failure, its nice to have this log
   sh 'cat /var/log/cloud-init.log'

   stage 'Clean'
   // Remove the app in the same workspace to avoid reusing packages, node modules etc.
   sh 'sudo rm -rf inventory-app/'

   stage 'Git Clone'
   // Clone the inventory app with the Github Bot user.
   sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app"

   // --------------------------Line by Line------------------------------------
   // ------------------------ First test to run -------------------------------

   stage 'Ready test env 1'
   // Clean up any left overs, if there are some, sometimes docker leavs orphans.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop || true'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f || true'
   sh 'sudo docker volume rm inventoryapp_rethink-data || true'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build --remove-orphans'

   stage 'Load the dealer data 1'
   // Here we are adding data by using scripts to insert real data.
   // Importing dealerships into RethinkDB
   sh 'cd inventory-app/dataimport/dealerships/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:dealerimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:dealerimport-0.1'

   stage 'Load the vehicle data 1'
   // Here we are adding data by using scripts to insert real data.
   // Import Vehicles and give them a random Dealership to belong to.
   sh 'cd inventory-app/dataimport/vehicles/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:vehicleimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:vehicleimport-0.1'

   stage 'Build and run test_http_dealers'
   // Run the tests in a Docker container.
   sh 'sudo docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/test_http_dealers.js"'

   stage 'Teardown 1'
   // Stop the application and database and clean up the Docker volume.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'

   // ------------------------ Second Test to run, repeat--------------------------

   stage 'Ready test env 2'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build --remove-orphans'

   stage 'Load the dealer data 2'
   // Here we are adding data by using scripts to insert real data.
   // Importing dealerships into RethinkDB
   sh 'cd inventory-app/dataimport/dealerships/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:dealerimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:dealerimport-0.1'

   stage 'Load the vehicle data 2'
   // Here we are adding data by using scripts to insert real data.
   // Import Vehicles and give them a random Dealership to belong to.
   sh 'cd inventory-app/dataimport/vehicles/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:vehicleimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:vehicleimport-0.1'

   stage 'Build and run test test_http_vehicles'
   // Run the tests in a Docker container.
   sh 'sudo docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/test_http_vehicles.js"'

   stage 'Teardown 2'
   // Stop the application and database and clean up the Docker volume.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'

   // ------------------------ Third Test to run, repeat--------------------------

   stage 'Ready test env 3'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build --remove-orphans'

   stage 'Load the dealer data 3'
   // Here we are adding data by using scripts to insert real data.
   // Importing dealerships into RethinkDB
   sh 'cd inventory-app/dataimport/dealerships/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:dealerimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:dealerimport-0.1'

   stage 'Load the vehicle data 3'
   // Here we are adding data by using scripts to insert real data.
   // Import Vehicles and give them a random Dealership to belong to.
   sh 'cd inventory-app/dataimport/vehicles/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:vehicleimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:vehicleimport-0.1'

   stage 'Build and run test test_http_ping'
   // Run the tests in a Docker container.
   sh 'sudo docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/test_http_vehicles.js"'

   stage 'Teardown 3'
   // Stop the application and database and clean up the Docker volume.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'

}
