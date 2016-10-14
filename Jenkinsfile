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

   stage 'Run tests with snapshots'
   // Now, instead of importing all the data from scripts, use a Flocker Hub Snapshot.
   String vs;
   String snap;
   if (env.BRANCH_NAME == "master"){
      // **********************************************
      //         Do not change unless proposing
      //         that master use a new snapshot
      // **********************************************
      // Volumeset the snapshot belongs to for master
      vs = 'inventory-app'
      // Snapshot used for tests in branch
      snap = 'initial-ia-snap'
      echo "Using Snapshot ${snap} for branch: master"
   }else{
      // **********************************************
      //  Set 'vs' and 'snap' below to use a different 
      //     branch for your build and tests in CI.
      // **********************************************
      // Volumeset the snapshot belongs to for dev branch
      vs = 'inventory-app'
      // Snapshot used for tests in branch
      snap = '750kvehicles'
      echo "Using Snapshot: ${snap} Branch: ${env.BRANCH_NAME}"
   }
   
   // Flocker Hub endpoint.
   def ep = "http://ec2-54-166-4-3.compute-1.amazonaws.com:8084"

   // Run the tests individually. This script is creating a new volume
   // from a snapshot locally and taking snapshots of the DB test results
   // then pushing the data back up to Flocker Hub with metadata and 
   // start fresh each time.
   sh "sudo inventory-app/ci-utils/runtests.sh ${vs} ${ep} ${snap} ${env.BRANCH_NAME} ${env.BUILD_NUMBER} ${env.BUILD_ID} ${env.BUILD_URL} '${env.NODE_NAME}'"
}

node ('v8s-dpcli-prov-staging') {
   stage 'Staging: Make sure cloud-init done'
   // Cloud-init runs on new jenkins slaves to install dpcli and docker, make sure its done.
   sh "timeout 1080 /bin/bash -c   'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting for boot to finish ...; sleep 10; done'"

   stage 'Staging: See cloud-init log'
   // In case of failure, its nice to have this log
   sh 'cat /var/log/cloud-init.log'

   stage 'Staging: Announce'
   echo "Starting staging on: '${env.NODE_NAME}'"

   stage 'Staging: Clean'
   // Remove the app in the same workspace to avoid reusing packages, node modules etc.
   // Staging will always create a <branch_name>-inventory-app/ directory instead
   // of without a prefix so containers run with prefixes of that directory. This helps
   // container names to not overlap if running multiple staging environments on the same
   // staging node.
   sh "sudo rm -rf ${env.BRANCH_NAME}-inventory-app/"

   stage 'Staging: Git Clone'
   // Clone the inventory app with the Github Bot user.
   //sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app ${env.BRANCH_NAME}-inventory-app/"

   stage 'Staging: Run staging environment'
   String staging_vs;
   String staging_snap;
   if (env.BRANCH_NAME == "master"){
      // **********************************************
      //         Do not change unless proposing
      //         that master use a new snapshot
      // **********************************************
      // Volumeset the snapshot belongs to for master
      staging_vs = 'inventory-app'
      // Snapshot used for tests in master
      staging_snap = 'initial-ia-snap'
      echo "Using Snapshot ${staging_snap} for branch: master"
   }else{
      // **********************************************
      //  Set 'vs' and 'snap' below to use a different 
      //     branch for your build and tests in CI.
      // **********************************************
      // Volumeset the snapshot belongs to for dev branch
      staging_vs = 'inventory-app'
      // Snapshot used for tests in master
      staging_snap = '750kvehicles'
      echo "Using Snapshot: ${staging_snap} Branch: ${env.BRANCH_NAME}"
   }

   // Flocker Hub endpoint.
   def staging_ep = "http://ec2-54-166-4-3.compute-1.amazonaws.com:8084"

   // Run staging
   sh "sudo ${env.BRANCH_NAME}-inventory-app/ci-utils/runstaging.sh ${staging_vs} ${staging_ep} ${staging_snap} ${env.BRANCH_NAME} ${env.BUILD_URL} ${env.BUILD_NUMBER}"
}
