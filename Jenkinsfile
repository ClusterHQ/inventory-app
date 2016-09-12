node ('v8s-dpcli-prov') {
   stage 'Make sure cloud-init done'
   sh "timeout 1080 /bin/bash -c   'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting for boot to finish ...; sleep 10; done'"
   stage 'See cloud-init log'
   // In case of failure, its nice to have this log
   sh 'cat /var/log/cloud-init.log'
   stage 'Clean'
   sh 'sudo rm -rf inventory-app/'
   stage 'Git Clone'
   sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app"
   stage 'Ready test env'
   // Clean up any left overs, if there are some.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop || true'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f || true'
   sh 'sudo docker volume rm inventoryapp_rethink-data || true'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build --remove-orphans'
   stage 'Load the dealer data'
   sh 'cd inventory-app/dataimport/dealerships/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:dealerimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:dealerimport-0.1'
   stage 'Load the vehicle data'
   sh 'cd inventory-app/dataimport/vehicles/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:vehicleimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:vehicleimport-0.1'
   stage 'Build and run tests'
   sh 'sudo docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/*.js"'
   stage 'Teardown'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'
   stage 'Pull snap create volume'
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
      snap = '7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae'
      echo "Using Snapshot: ${vs} Branch: ${env.BRANCH_NAME}"
   }
   // Flocker Hub endpoint.
   def ep = "http://ec2-54-234-205-145.compute-1.amazonaws.com"
   sh "sudo inventory-app/ci-utils/use_snap.sh ${vs} ${snap} ${ep}"
   stage "Start with snapshot"
   // output so we can debug whether snapshot was placed.
   sh 'cat inventory-app/docker-compose.yml'
   // Do not need to use --build since we built it earlier.
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build --remove-orphans'
   stage 'Build and run tests against snapshot data'
   sh 'sudo docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && rm -rf node_modules && npm install && mocha --debug test/*.js"'
   stage 'The final teardown'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'
   stage 'Sync snap push'
   sh "sudo inventory-app/ci-utils/snapnpush.sh ${vs} ${ep} ${env.BRANCH_NAME} ${env.BUILD_NUMBER} ${env.BUILD_ID} ${env.BUILD_URL} ${env.NODE_NAME}"
   stage 'Done'
   echo "Done"
}
