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

   stage 'Ready test env'
   // Clean up any left overs, if there are some, sometimes docker leavs orphans.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop || true'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f || true'
   sh 'sudo docker volume rm inventoryapp_rethink-data || true'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build --remove-orphans'

   stage 'Load the dealer data'
   // Here we are adding data by using scripts to insert real data.
   // Importing dealerships into RethinkDB
   sh 'cd inventory-app/dataimport/dealerships/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:dealerimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:dealerimport-0.1'

   stage 'Load the vehicle data'
   // Here we are adding data by using scripts to insert real data.
   // Import Vehicles and give them a random Dealership to belong to.
   sh 'cd inventory-app/dataimport/vehicles/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:vehicleimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:vehicleimport-0.1'

   stage 'Build and run tests'
   // Run the tests in a Docker container.
   sh 'sudo docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/*.js"'

   stage 'Teardown'
   // Stop the application and database and clean up the Docker volume.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'

   stage 'Pull snap create volume'
   // Now, instead of importing all the data from scripts, use a Flocker Hub Snapshot.
   String vs;
   String snap;
   if (env.BRANCH_NAME == "master"){
      // **********************************************
      //         Do not change unless proposing
      //         that master use a new snapshot
      // **********************************************
      // Volumeset the snapshot belongs to for master
      vs = '1734c879-641c-41cd-92b5-f47704338a1d'
      // Snapshot used for tests in master
      snap = '7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae'
      echo "Using Snapshot ${vs} for branch: master"
   }else{
      // **********************************************
      //  Set 'vs' and 'snap' below to use a different 
      //     branch for your build and tests in CI.
      // **********************************************
      // Volumeset the snapshot belongs to for dev branch
      vs = '1734c879-641c-41cd-92b5-f47704338a1d'
      // Snapshot used for tests in branch
      // e.g. 7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae
      snap = '7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae'
      echo "Using Snapshot: ${vs} Branch: ${env.BRANCH_NAME}"
   }
   // Flocker Hub endpoint.
   def ep = "http://ec2-54-234-205-145.compute-1.amazonaws.com"

   stage 'Run tests with snapshots'
   // Run the tests individually taking snapshots between each of them
   // and starting fresh each time.
   sh "sudo inventory-app/ci-utils/runtests.sh ${vs} ${ep} ${snap} ${env.BRANCH_NAME} ${env.BUILD_NUMBER} ${env.BUILD_ID} ${env.BUILD_URL} '${env.NODE_NAME}'"
}
