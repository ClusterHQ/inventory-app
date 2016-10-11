stage 'Run tests in parallel'
parallel 'parallel tests 1':{
    node('v8s-dpcli-prov'){
      run_group('test_http_ping', 'd6c5441a-9af2-47d5-9010-3c6e5ccad672', 'inventory-app')
    }
}, 'parallel tests 2':{
    node('v8s-dpcli-prov'){
      run_group('test_http_dealers', 'd6c5441a-9af2-47d5-9010-3c6e5ccad672', 'inventory-app')
    }
}, 'parallel tests 3':{
    node('v8s-dpcli-prov'){
      run_group('test_http_vehicles', 'd6c5441a-9af2-47d5-9010-3c6e5ccad672', 'inventory-app')
    }
}

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
      // Snapshot used for tests in master
      snap = 'd6c5441a-9af2-47d5-9010-3c6e5ccad672'
      echo "Using Snapshot ${vs} for branch: master"
   }else{
      // **********************************************
      //  Set 'vs' and 'snap' below to use a different 
      //     branch for your build and tests in CI.
      // **********************************************
      // Volumeset the snapshot belongs to for dev branch
      vs = "${volumeset}"
      // Snapshot used for tests in branch
      // e.g. 7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae
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
