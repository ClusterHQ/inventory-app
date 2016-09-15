#!/usr/bin/env bash

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

RUNTEST=$1
VOLUMESET=$2
HUBENDPOINT=$3
SNAP=$4
GITBRANCH=$5
JENKINSBUILDN=$6
JENKINSBUILDID=$7
JENKINSBUILDURL=$8
JENKINSNODE=$9

# Test will be used as a holder for current test.
TEST=$RUNTEST
FAILED=false
FAILED_TESTS=()

use_snapshot() {
   echo "Use a specific snapshot"
   # Run `use_snap.sh` which pulls and creates volume from snapshot.
   # this script with modify in place the docker-compose.yml file
   # and add the /chq/<UUID> volume.
   inventory-app/ci-utils/use_snap.sh ${VOLUMESET} ${SNAP} ${HUBENDPOINT}
}

start_app() {
   echo "Start with snapshot"
   # Start the application with the volume-from-snapshot.
   # Output so we can debug whether snapshot was placed
   # and start the compose app.
   cat inventory-app/docker-compose.yml
   /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build --remove-orphans
}

snap_with_failure() {
   echo "[FAILED TEST ${TEST}]: Taking snapshot of database and pushing it"
   FAILED_TESTS+=($TEST)
   FAILED=true
   # Take a snapshot of the volume from snapshot used in tests to capture
   # the state of the database after the tests , also include specific information
   # about the branch, build, build number etc.
   inventory-app/ci-utils/snapnpush.sh ${VOLUMESET} ${HUBENDPOINT} ${GITBRANCH} ${JENKINSBUILDN} ${JENKINSBUILDID} ${JENKINSBUILDURL} "Failed-${TEST}" "${JENKINSNODE}"
}

run_test() {
   echo "Build and run tests against snapshot data"
   # Run the tests against the application using the snapshot
   # (Should have same results as above, but with using a snapshot)
   docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest \
      "cd /app/frontend && rm -rf node_modules && npm install && mocha --debug test/${TEST}.js" || snap_with_failure
}

teardown() {
   echo "The final teardown"
   # Tear down the application and database again.
   /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop
   /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f
   docker volume rm inventoryapp_rethink-data
}

snapnpush() {
   echo "Sync snap push"
   # Take a snapshot of the volume from snapshot used in tests to capture
   # the state of the database after the tests, also include specific information
   # about the branch, build, build number etc.
   inventory-app/ci-utils/snapnpush.sh ${VOLUMESET} ${HUBENDPOINT} ${GITBRANCH} ${JENKINSBUILDN} ${JENKINSBUILDID} ${JENKINSBUILDURL} ${TEST} "${JENKINSNODE}"
}

run_group() {
   echo "Running test: inventory-app.test.${TEST} with snapshot: ${SNAP}"
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
      exit 1; 
   fi
}


TESTS=("test_http_ping" "test_http_dealers" "test_http_vehicles")
for i in "${TESTS[@]}"
do
   TEST=$i
   run_group
done
check_if_failed
