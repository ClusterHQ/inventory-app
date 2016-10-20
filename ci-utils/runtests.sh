#!/usr/bin/env bash

set -e

# Script to run tests.
# Needs to be run as SUDO

# -------------------- Params ---------------------------------------
# VOLUMESET        is a Flocker Hub Volumeset, which owns snapshots and variants
# HUBENDPOINT      is the Flocker Hub URL endpoint used by the CLI.
# SNAP             is a Flocker Hub Snapshot
# GITBRANCH        is the Github Branch name being built, it is provided by the Jenkins env.
# JENKINSBUILDN    is the Jenkins Build Number, it is provided by the Jenkins env.
# JENKINSBUILDID   is the Jenkins Build ID, it is provided by the Jenkins env.
# JENKINSBUILDURL  is the Jenkins Build ID URL, it is provided by the Jenkins env.
# JENKINSNODE      is the Jenkins node the snapshot was used on in the build,
#                  it is provided by the Jenkins env.
# --------------------- END -----------------------------------------

VOLUMESET=$1
HUBENDPOINT=$2
SNAP=$3
GITBRANCH=$4
JENKINSBUILDN=$5
JENKINSBUILDID=$6
JENKINSBUILDURL=$7
JENKINSNODE=$8
ENV="ci"

# Test will be used as a holder for current test.
TEST=""
FAILED=false
FAILED_TESTS=()

fli='docker run --privileged -v /chq:/chq:shared -v /root:/root -v /lib/modules:/lib/modules clusterhq/fli'

check_for_failure() {
   if [ $? -eq 0 ]; then
      echo "OK"
   else
      echo "FAIL"
      exit 1
   fi
}

init_fli(){
   # Check if init has been run or if its a new slave.
   if [ ! -f /tmp/fliinitdone ]; then
      $fli setup --zpool chq || true
      # **********************************
      # The first volume never seems to get
      # actually populated on the FS. (Dev Issue)
      # will likely remove this later on. (TODO)
      $fli init  someVolumeSet
      $fli create someVolumeSet someVolume
      # **********************************
      touch /tmp/fliinitdone
      check_for_failure
      # vhut token is set as a secret inside the jenkins master
      $fli config -t /root/fh.token
      check_for_failure
      $fli config -u $HUBENDPOINT
      check_for_failure
   fi
}

use_snapshot() {
   echo "Use a specific snapshot"
   # Run `use_snap.sh` which pulls and creates volume from snapshot.
   # this script with modify in place the docker-compose.yml file
   # and add the /chq/<UUID> volume.
   inventory-app/ci-utils/use_snap.sh ${VOLUMESET} ${SNAP} ${GITBRANCH} ${ENV} ${JENKINSBUILDN}
}

start_app() {
   echo "Start with snapshot"
   # Start the application with the volume-from-snapshot.
   # Output so we can debug whether snapshot was placed
   # and start the compose app.
   cat inventory-app/docker-compose.yml
   /usr/local/bin/docker-compose -p inventory -f inventory-app/docker-compose.yml up -d --build --remove-orphans
}

snap_with_failure() {
   echo "[FAILED TEST ${TEST}]: Taking snapshot of database and pushing it"
   FAILED_TESTS+=($TEST)
   FAILED=true
   # Take a snapshot of the volume from snapshot used in tests to capture
   # the state of the database after the tests , also include specific information
   # about the branch, build, build number etc.
   inventory-app/ci-utils/snapnpush.sh ${VOLUMESET} ${GITBRANCH} ${JENKINSBUILDN} ${JENKINSBUILDID} ${JENKINSBUILDURL} "Failed-${TEST}" "${JENKINSNODE}"
}

run_test() {
   echo "Build and run tests against snapshot data"
   # Run the tests against the application using the snapshot
   # (Should have same results as above, but with using a snapshot)
   docker run --net=inventory_net -e FRONTEND_HOST="frontend" -e DATABASE_HOST="db" -e FRONTEND_PORT=8000 --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest \
      "cd /app/frontend && rm -rf node_modules && npm install && mocha --debug test/${TEST}.js" || snap_with_failure
}

teardown() {
   echo "The final teardown"
   # Tear down the application and database again.
   /usr/local/bin/docker-compose -p inventory -f inventory-app/docker-compose.yml stop
   /usr/local/bin/docker-compose -p inventory -f inventory-app/docker-compose.yml rm -f
   docker volume rm inventory_rethink-data || true
}

snapnpush() {
   echo "Sync snap push"
   # Take a snapshot of the volume from snapshot used in tests to capture
   # the state of the database after the tests, also include specific information
   # about the branch, build, build number etc.
   inventory-app/ci-utils/snapnpush.sh ${VOLUMESET} ${GITBRANCH} ${JENKINSBUILDN} ${JENKINSBUILDID} ${JENKINSBUILDURL} ${TEST} "${JENKINSNODE}"
   check_for_failure
}

run_group() {
   echo "Running test: inventory-app.test.${TEST} with snapshot: ${SNAP}"
   init_fli
   use_snapshot
   start_app
   run_test
   teardown
   snapnpush
}

check_if_failed() {
   echo "Checking for failures..."
   if $FAILED ; then 
      echo "Found failed tests: ${FAILED_TESTS[@]}"
      cat testfailures.txt
      exit 1; 
   fi
}

# Get all tests but seperately 
IFS=' ' read -r -a TESTS <<< $(ls inventory-app/frontend/test/ | grep "test_" | tr "\n" " ")
check_for_failure
for i in "${TESTS[@]}"
do
   # Run the test wrapped in a 
   # create from snap, snap, push.
   TEST=${i//.js}
   run_group
done
unset IFS
check_if_failed

