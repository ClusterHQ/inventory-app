#!/usr/bin/env bash

set -e

# This script will take a Flocker Hub endpoint, volumeset
# and snapshot as arguments and create a volume from the
# snapshot and change the `- rethink-data:` volume to
# use that snapshot.

# -------------------- Params ---------------------------------------
# VS     is a Flocker Hub Volumeset, which owns snapshots and variants
# SNAP   is a Flocker Hub Snapshot
# VPATH  is the /chq/UUID path returned by `dpcli create volume`
# ENV    is the deployment environment CI/CD (ci) or Staging (staging)
# BUILDN is the Jenkins Build Number
# --------------------- END -----------------------------------------

VS=$1
SNAP=$2
BRANCH=$3
ENV=$4
BUILDN=$5

# Check for "needed" vars
if [ -z "$VS" ]; then
    echo "VS was unset, exiting"
    exit 1
fi  

if [ -z "$SNAP" ]; then
    echo "SNAP was unset, exiting"
    exit 1
fi

export PATH=$PATH:/usr/local/sbin/
/opt/clusterhq/bin/dpcli sync volumeset $VS
# BRANCH, NAME, ID, SIZE, we want ID so get 3rd
# but sometimes values are blank... :( so we want 2nd.
# need something like `dpcli get volume-path <volume-name>
# BRANCH                  NAME            ID     SIZE ...
# inventory-app-branch    initial_ia_snap <uuid> 0B   ...
#                         initial_ia_snap <UUID> 0B   ...
IDOFSNAP=$(/opt/clusterhq/bin/dpcli show snapshot -v ${VS} | grep ${SNAP} | head -1 | awk '{print $3}')
if [[ "$IDOFSNAP" == *B ]]
then
	echo "volume didnt have branch name, using other method"
	IDOFSNAP=$(/opt/clusterhq/bin/dpcli show snapshot -v ${VS} | grep ${SNAP} | head -1 | awk '{print $2}')
fi
/opt/clusterhq/bin/dpcli pull snapshot $IDOFSNAP
VPATH=$(/opt/clusterhq/bin/dpcli create volume -s $IDOFSNAP volumeFrom-$SNAP-$BUILDN | grep -E -o  '\/chq\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')

# load the Volume Path into compose. later we can use `fli-docker`
# to eliminate the need for this being bash. 
# will become 1) create manifest dynamically, 2)`fli-docker -f manifest.yml`
if [ "${ENV}" == "staging" ]; then
	/usr/bin/sed -i 's@\- rethink-data:@\- '"${VPATH}"':@' ${BRANCH}-inventory-app/docker-compose.yml
elif [ "${ENV}" == "ci" ]; then
	if [ ! -f inventory-app/composecopied ]; then
    	# if this is the first run, make sure we make a copy of the original
    	# because CI will run tests individually, changing the volume each time.
    	echo "First run, copying original compose file"
    	cp inventory-app/docker-compose.yml inventory-app/docker-compose.yml.orig
    	touch inventory-app/composecopied
    	/usr/bin/sed -i 's@\- rethink-data:@\- '"${VPATH}"':@' inventory-app/docker-compose.yml
	else
    	# copy the un-touched original before adding the Flocker Hub Volume
    	cp inventory-app/docker-compose.yml.orig inventory-app/docker-compose.yml
    	/usr/bin/sed -i 's@\- rethink-data:@\- '"${VPATH}"':@' inventory-app/docker-compose.yml
	fi
else
	echo "Environemt [${ENV}] not recognized"
	exit 1
fi
