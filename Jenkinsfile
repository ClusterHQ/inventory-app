stage 'Run tests in parallel'
parallel 'parallel tests 1':{
    node('v8s-dpcli-prov'){
      run_group('test_http_ping', '750krecords', 'inventory-app')
    }
}, 'parallel tests 2':{
    node('v8s-dpcli-prov'){
      //run_group('test_db_dealer_numbers', 'badphonenumber', 'inventory-app')
      run_group('test_db_dealer_numbers', '750krecords', 'inventory-app')
    }
}, 'parallel tests 3':{
    node('v8s-dpcli-prov'){
      //run_group('test_db_vehicle_vins', 'badvinnumber', 'inventory-app')
      run_group('test_db_vehicle_vins', '750krecords', 'inventory-app')
    }
}, 'parallel tests 4':{
    node('v8s-dpcli-prov'){
      run_group('test_http_dealers_getdealerships', '750krecords', 'inventory-app')
    }
}, 'parallel tests 5':{
    node('v8s-dpcli-prov'){
      run_group('test_http_dealers_postdealership', '750krecords', 'inventory-app')
    }
}, 'parallel tests 6':{
    node('v8s-dpcli-prov'){
      run_group('test_http_dealers_postgetdealers', '750krecords', 'inventory-app')
    }
}, 'parallel tests 7':{
    node('v8s-dpcli-prov'){
      run_group('test_http_vehicles_getvehicles', '750krecords', 'inventory-app')
    }
}, 'parallel tests 8':{
    node('v8s-dpcli-prov'){
      run_group('test_http_vehicles_postgetvehicle', '750krecords', 'inventory-app')
    }
}, 'parallel tests 9':{
    node('v8s-dpcli-prov'){
      run_group('test_http_vehicles_postvehicle', '750krecords', 'inventory-app')
    }
}

//run_group(test_to_run, Snapshot, VolumeSet)
def run_group(test, volsnap, volset) {

   def run_test = test
   def snapshot = volsnap
   def volumeset = volset


   // Cloud-init runs on new jenkins slaves to install dpcli and docker, make sure its done.
   sh "timeout 1080 /bin/bash -c   'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting for boot to finish ...; sleep 10; done'"

   // In case of failure, its nice to have this log
   sh 'cat /var/log/cloud-init.log'

   // Remove the app in the same workspace to avoid reusing packages, node modules etc.
   sh 'sudo rm -rf inventory-app/'

   // Clone the inventory app with the Github Bot user.
   sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app"

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
      snap = '750krecords'
      echo "Using Snapshot ${vs} for branch: master"
   }else{
      // **********************************************
      //  Set 'vs' and 'snap' below to use a different 
      //     branch for your build and tests in CI.
      // **********************************************
      // Volumeset the snapshot belongs to for dev branch
      vs = "${volumeset}"
      // Snapshot used for tests in branch
      snap = "${snapshot}"
      echo "Using Snapshot: ${vs} Branch: ${env.BRANCH_NAME}"
   }
   
   // Flocker Hub endpoint.
   def ep = "http://ec2-54-166-4-3.compute-1.amazonaws.com:8084"

   // Run the tests individually. This script is creating a new volume
   // from a snapshot locally and taking snapshots of the DB test results
   // then pushing the data back up to Flocker Hub with metadata and 
   // start fresh each time.

   // use ci-utils/runtest.sh (not runtests.sh)
   sh "sudo inventory-app/ci-utils/runtest.sh ${run_test} ${vs} ${ep} ${snap} ${env.BRANCH_NAME} ${env.BUILD_NUMBER} ${env.BUILD_ID} ${env.BUILD_URL} '${env.NODE_NAME}'"

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
   sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app ${env.BRANCH_NAME}-inventory-app/"

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
      staging_snap = '750krecords'
      echo "Using Snapshot ${staging_snap} for branch: master"
   }else{
      // **********************************************
      //  Set 'vs' and 'snap' below to use a different 
      //     branch for your build and tests in CI.
      // **********************************************
      // Volumeset the snapshot belongs to for dev branch
      staging_vs = 'inventory-app'
      // Snapshot used for tests in master
      staging_snap = '750krecords'
      echo "Using Snapshot: ${staging_snap} Branch: ${env.BRANCH_NAME}"
   }

   // Flocker Hub endpoint.
   def staging_ep = "http://ec2-54-166-4-3.compute-1.amazonaws.com:8084"

   // Run staging
   sh "sudo ${env.BRANCH_NAME}-inventory-app/ci-utils/runstaging.sh ${staging_vs} ${staging_ep} ${staging_snap} ${env.BRANCH_NAME} ${env.BUILD_URL} ${env.BUILD_NUMBER}"
}
