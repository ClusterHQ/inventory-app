#!/usr/bin/env bash

# This script will take a Flocker Hub endpoint, volumeset
# and snapshot as arguments and create a volume from the
# snapshot and change the `- rethink-data:` volume to
# use that snapshot.

# -------------------- Params ---------------------------------------
# VS     is a Flocker Hub Volumeset, which owns snapshots and variants
# SNAP   is a Flocker Hub Snapshot
# EP     is the Flocker Hub URL endpoint used by the CLI.
# VPATH  is the /chq/UUID path returned by `dpcli create volume`
# --------------------- END -----------------------------------------

VS=$1
SNAP=$2
EP=$3
BRANCH=$4
ENV=$5

# Check for "needed" vars
if [ -z "$VS" ]; then
    echo "VS was unset, exiting"
    exit 1
fi  

if [ -z "$SNAP" ]; then
    echo "SNAP was unset, exiting"
    exit 1
fi

if [ -z "$EP" ]; then
    echo "EP was unset, exiting"
    exit 1
fi  

# should always check for init, but not fail if init already done.
export PATH=$PATH:/usr/local/sbin/
/opt/clusterhq/bin/dpcli init || true
# vhut token is set as a secret inside the jenkins master
/opt/clusterhq/bin/dpcli set tokenfile /root/vhut.txt
/opt/clusterhq/bin/dpcli set volumehub $EP
/opt/clusterhq/bin/dpcli sync volumeset $VS
/opt/clusterhq/bin/dpcli pull snapshot $SNAP
VPATH=$(/opt/clusterhq/bin/dpcli create volume -s $SNAP | grep -E -o  '\/chq\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')

if [ "${ENV}" == "staging" ]; then
	/usr/bin/sed -i 's@\- rethink-data:@\- '"${VPATH}"':@' ${BRANCH}-inventory-app/docker-compose.yml
elif [ "${ENV}" == "ci" ]; then
	if [ ! -f inventory-app/composecopied ]; then
		# If this is the first run, make sure we make a copy of the original
		# because CI will run tests individually, changing the volume each time.
    	echo "First run, copying original compose file"
    	cp inventory-app/docker-compose.yml inventory-app/docker-compose.yml.orig
    	touch inventory-app/composecopied
    	/usr/bin/sed -i 's@\- rethink-data:@\- '"${VPATH}"':@' inventory-app/docker-compose.yml
    else
    	# Copy the un-touched original before adding the Flocker Hub Volume
    	cp inventory-app/docker-compose.yml.orig inventory-app/docker-compose.yml
    	/usr/bin/sed -i 's@\- rethink-data:@\- '"${VPATH}"':@' inventory-app/docker-compose.yml
	fi
else
	echo "Environemt [${ENV}] not recognized"
	exit 1
fi
