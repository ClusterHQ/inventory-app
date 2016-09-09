#!/bin/bash

# This script should only be used when the
# volume defined in docker-compose.yml should
# need to be snapshotted and pushed. 

# This script will take the volume and snapshot 
# that volume with metadata about the branch 
# and build and push it back to Flocker Hub.

# -------------------- Params ---------------------------------------
# VOLUMESET        is a Flocker Hub Volumeset, which owns snapshots and variants
# HUBENDPPOINT     is the Flocker Hub URL endpoint used by the CLI.
# GITBRANCH        is the Github Branch name being built, it is provided by the Jenkins env.
# JENKINSBUILDN    is the Jenkins Build Number, it is provided by the Jenkins env.
# JENKINSBUILDID   is the Jenkins Build ID, it is provided by the Jenkins env.
# JENKINSBUILDURL  is the Jenkins Build ID URL, it is provided by the Jenkins env.
# JENKINSNODE      is the Jenkins node the snapshot was used on in the build,
#                  it is provided by the Jenkins env.
# --------------------- END -----------------------------------------

VOLUMESET=$1
HUBENDPPOINT=$2
GITBRANCH=$3
JENKINSBUILDN=$4
JENKINSBUILDID=$5
JENKINSBUILDURL=$6
JENKINSNODE=$7

# Check for "needed" vars
if [ -z "$VOLUMESET" ]; then
    echo "VOLUMESET was unset, exiting"
    exit 1
fi  

if [ -z "$HUBENDPPOINT" ]; then
    echo "HUBENDPPOINT was unset, exiting"
    exit 1
fi  

WORKINGVOL=$(cat inventory-app/docker-compose.yml | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
/opt/clusterhq/bin/dpcli set --vhub $HUBENDPPOINT
# We may be able to use just the Github branch name as the dpcli
# branch but right now we run into VOL-201 
PATH=$PATH:/usr/local/sbin/
VOLSNAP=$(/opt/clusterhq/bin/dpcli create snapshot --volume $WORKINGVOL --branch "${GITBRANCH}-build-${JENKINSBUILDN}" --message "Snap for build ${JENKINSBUILDN}, build id ${JENKINSBUILDID} build URL ${JENKINSBUILDURL} built on ${JENKINSNODE}" 2>&1 | grep "New Snapshot ID:" | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
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

/opt/clusterhq/bin/dpcli sync volumeset $VS
/opt/clusterhq/bin/dpcli push snapshot $SNAP
/opt/clusterhq/bin/dpcli show snapshot --volumeset $VS
