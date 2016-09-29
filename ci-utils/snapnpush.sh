#!/usr/bin/env bash

set -e

# This script should only be used when the
# volume defined in docker-compose.yml should
# need to be snapshotted and pushed. 

# This script will take the volume and snapshot 
# that volume with metadata about the branch 
# and build and push it back to Flocker Hub.

# -------------------- Params ---------------------------------------
# VOLUMESET        is a Flocker Hub Volumeset, which owns snapshots and variants
# HUBENDPOINT      is the Flocker Hub URL endpoint used by the CLI.
# GITBRANCH        is the Github Branch name being built, it is provided by the Jenkins env.
# JENKINSBUILDN    is the Jenkins Build Number, it is provided by the Jenkins env.
# JENKINSBUILDID   is the Jenkins Build ID, it is provided by the Jenkins env.
# JENKINSBUILDURL  is the Jenkins Build ID URL, it is provided by the Jenkins env.
# TEST			   is the Test that was run with the snapshot.
# JENKINSNODE      is the Jenkins node the snapshot was used on in the build,
#                  it is provided by the Jenkins env.
# --------------------- END -----------------------------------------

VOLUMESET=$1
HUBENDPOINT=$2
GITBRANCH=$3
JENKINSBUILDN=$4
JENKINSBUILDID=$5
JENKINSBUILDURL=$6
TEST=$7
JENKINSNODE=$8

# Check for "needed" vars
if [ -z "$VOLUMESET" ]; then
    echo "VOLUMESET was unset, exiting"
    exit 1
fi  

if [ -z "$HUBENDPOINT" ]; then
    echo "HUBENDPOINT was unset, exiting"
    exit 1
fi  

WORKINGVOL=$(cat inventory-app/docker-compose.yml | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
PATH=$PATH:/usr/local/sbin/
/opt/clusterhq/bin/dpcli set tokenfile /root/vhut.txt
/opt/clusterhq/bin/dpcli set volumehub $HUBENDPOINT
# We may be able to use just the Github branch name as the dpcli
# branch but right now we run into VOL-201 
echo "/opt/clusterhq/bin/dpcli create snapshot --volume $WORKINGVOL --branch ${GITBRANCH}-test-${TEST}-build-${JENKINSBUILDN} -a jenkins_build_number=${JENKINSBUILDN},build_id=${JENKINSBUILDID},build_URL=${JENKINSBUILDURL},ran_test=${TEST},built_on_jenkins_vm=${JENKINSNODE//[[:blank:]]/}"
VOLSNAP=$(/opt/clusterhq/bin/dpcli create snapshot --volume $WORKINGVOL --branch ${GITBRANCH}-test-${TEST}-build-${JENKINSBUILDN} -a jenkins_build_number=${JENKINSBUILDN},build_id=${JENKINSBUILDID},build_URL=${JENKINSBUILDURL},ran_test=${TEST},built_on_jenkins_vm=${JENKINSNODE//[[:blank:]]/} | grep "New Snapshot ID:" | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
echo "Took snapshot: ${VOLSNAP} of volume: ${WORKINGVOL}"

# Were we succesfull at getting VOL / SNAP?
if [ -z "$VOLSNAP" ]; then
    echo "VOLSNAP was unset, exiting"
    exit 1
fi  

if [ -z "$WORKINGVOL" ]; then
    echo "WORKINGVOL was unset, exiting"
    exit 1
fi  

/opt/clusterhq/bin/dpcli sync volumeset $VOLUMESET
/opt/clusterhq/bin/dpcli push snapshot $VOLSNAP

# This will only work if VOLUMESET is the UUID for
# versions before September 25. Using human readable
# names was added after this, so this may be blank
# if using and older version.
# SO we use the UUID just in case.
IDOFSET=$(/opt/clusterhq/bin/dpcli show volumeset | grep $VOLUMESET | cut -d" " -f2)
echo "Showing specific snapshots for this build"
/opt/clusterhq/bin/dpcli show snapshot --volumeset $IDOFSET | grep "${GITBRANCH}-test-.*-build-${JENKINSBUILDN}"