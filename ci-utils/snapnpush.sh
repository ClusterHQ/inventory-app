#!/bin/sh

# This script should only be used when the
# volume defined in docker-compose.yml should
# need to be snapshotted and pushed. 

# This script #will take the volume and snapshot 
# that volume with metadata about the branch 
# and build and push it back to Flocker Hub.

# -------------------- Params ---------------------------------------
# VS        is a Flocker Hub Volumeset, which owns snapshots and variants
# EP        is the Flocker Hub URL endpoint used by the CLI.
# BRANCH    is the Github Branch name being built, it is provided by the Jenkins env.
# BRANCHN   is the Jenkins Build Number, it is provided by the Jenkins env.
# BUILDID   is the Jenkins Build ID, it is provided by the Jenkins env.
# BUILD URL is the Jenkins Build ID URL, it is provided by the Jenkins env.
# NODE      is the Jenkins node the snapshot was used on in the build,
#           it is provided by the Jenkins env.
# --------------------- END -----------------------------------------

VS=$1
EP=$2
BRANCH=$3
BUILDN=$4
BUILDID=$5
BUILDURL=$6
NODE=$7

# Check for "needed" vars
if [ -z "$VS" ]; then
    echo "VS was unset, exiting"
    exit 1
fi  

if [ -z "$EP" ]; then
    echo "EP was unset, exiting"
    exit 1
fi  

export PATH=${PATH}:/usr/local/sbin/
VOL=$(cat inventory-app/docker-compose.yml | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
/opt/clusterhq/bin/dpcli set --vhub $EP
# We may be able to use just the Github branch name as the dpcli
# branch but right now we run into https://clusterhq.atlassian.net/browse/VOL-201 
SNAP=$(/opt/clusterhq/bin/dpcli create snapshot --volume ${VOL:?VOL is unset} --branch "${BRANCH}-build-${BUILDN}" --message "Snap for build ${BUILDN}, build id ${BUILDID} build URL ${BUILDURL} built on ${NODE}" 2>&1 | grep "New Snapshot ID:" | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
echo "Took snapshot: ${SNAP} of volume: ${VOL}"

# Were we succesfull at getting VOL / SNAP?
if [ -z "$SNAP" ]; then
    echo "SNAP was unset, exiting"
    exit 1
fi  

if [ -z "$VOL" ]; then
    echo "VOL was unset, exiting"
    exit 1
fi  

/opt/clusterhq/bin/dpcli sync volumeset $VS
/opt/clusterhq/bin/dpcli push snapshot $SNAP
/opt/clusterhq/bin/dpcli show snapshot --volumeset $VS
