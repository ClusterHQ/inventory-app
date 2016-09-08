#!/bin/sh

# This script should only be used when the
# volume defined in docker-compose.yml should
# need to be snapshotted and pushed. 

# This script #will take the volume and snapshot 
# that volume with metadata about the branch 
# and build and push it back to Flocker Hub.

VS=$1
EP=$2

VOL=$(cat inventory-app/docker-compose.yml | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
/opt/clusterhq/bin/dpcli set --vhub $EP
echo $VOL
SNAP=$(/opt/clusterhq/bin/dpcli create snapshot \
	--volume ${VOL:?VOL is unset} \
	--branch "${BRANCH_NAME}" \
	--message "Snap for build ${BUILD_NUMBER}, \
	build id ${BUILD_ID} build URL ${BUILD_URL} built on ${NODE_NAME}" 2>&1 | \
	grep "New Snapshot ID:" | grep -E -o  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
echo $SNAP
/opt/clusterhq/bin/dpcli sync volumeset $VS
/opt/clusterhq/bin/dpcli push snapshot $SNAP
/opt/clusterhq/bin/dpcli show snapshot --volumeset $VS