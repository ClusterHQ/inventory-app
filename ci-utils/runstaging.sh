#!/usr/bin/env bash

set -e

# Script to run staging
# Needs to be run as SUDO

# -------------------- Params ---------------------------------------
# VOLUMESET        is a Flocker Hub Volumeset, which owns snapshots and variants
# HUBENDPOINT      is the Flocker Hub URL endpoint used by the CLI.
# SNAP             is a Flocker Hub Snapshot
# GITBRANCH        is the Github Branch name being built, it is provided by the Jenkins env.
# JENKINSBUILDURL  is the Jenkins Build ID URL, it is provided by the Jenkins env.
# --------------------- END -----------------------------------------

VOLUMESET=$1
HUBENDPOINT=$2
SNAP=$3
GITBRANCH=$4
JENKINSBUILDURL=$5
ENV="staging"

init_fli(){
   # Check if init has been run or if its a new slave.
   if [ ! -f inventory-app/fliinitdone ]; then
      /opt/clusterhq/bin/dpcli init --zpool chq -f || true
      touch inventory-app/fliinitdone
      # vhut token is set as a secret inside the jenkins master
      /opt/clusterhq/bin/dpcli set tokenfile /root/vhut.txt
      /opt/clusterhq/bin/dpcli set volumehub $HUBENDPOINT
}

use_snapshot() {
   echo "Use a specific snapshot"
   # Run `use_snap.sh` which pulls and creates volume from snapshot.
   # this script with modify in place the docker-compose.yml file
   # and add the /chq/<UUID> volume.
   ${GITBRANCH}-inventory-app/ci-utils/use_snap.sh ${VOLUMESET} ${SNAP} ${GITBRANCH} ${ENV}
}

start_app() {
   echo "Start with snapshot"
   # Start the application with the volume-from-snapshot.
   # Output so we can debug whether snapshot was placed
   # and start the compose app.
   cat ${GITBRANCH}-inventory-app/docker-compose.yml
   /usr/local/bin/docker-compose -f ${GITBRANCH}-inventory-app/docker-compose.yml up -d --build --remove-orphans
   # Show the containers in the log so we know what port to access.
   # we could use more accurate filtering, see https://docs.docker.com/engine/reference/commandline/ps/
   docker ps --last 2
}

# Used in teardown() and publish_staging_env()
L_NO_DASH_GITBRANCH=$(echo ${GITBRANCH//-} | tr '[:upper:]' '[:lower:]')

teardown() {
   echo "Teardown app if running"
   # Tear down the application and database again.
   /usr/local/bin/docker-compose -f ${GITBRANCH}-inventory-app/docker-compose.yml stop
   /usr/local/bin/docker-compose -f ${GITBRANCH}-inventory-app/docker-compose.yml rm -f
   docker volume rm ${L_NO_DASH_GITBRANCH}inventoryapp_rethink-data || true
}

publish_staging_env() {
   host=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
   frontend_port=$(cut -d ":" -f 2 <<< $(sudo docker port ${L_NO_DASH_GITBRANCH}inventoryapp_frontend_1))
   rethinkdb_port=$(cut -d ":" -f 2 <<< $(sudo docker port ${L_NO_DASH_GITBRANCH}inventoryapp_db_1 | grep 28015))
   rethinkdb_ui_port=$(cut -d ":" -f 2 <<< $(sudo docker port ${L_NO_DASH_GITBRANCH}inventoryapp_db_1 | grep 8080))
   echo "Your staging environment is available at ${host}:${frontend_port}"
   echo "Your staging database is available at ${host}:${rethinkdb_port}"
   echo "Your staging database UI is available at ${host}:${rethinkdb_ui_port}"
}


run_group() {
   echo "Bringing up staging for ${GITBRANCH}-inventory-app with snapshot: ${SNAP}"
   teardown
   use_snapshot
   start_app
   publish_staging_env
}

run_group

