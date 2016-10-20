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

alias fli='docker run --privileged -v /chq/:/chq/ -v /root:/root -v /lib/modules:/lib/modules clusterhq/fli'

# Check for "needed" vars
if [ -z "$VS" ]; then
    echo "VS was unset, exiting"
    exit 1
fi  

if [ -z "$SNAP" ]; then
    echo "SNAP was unset, exiting"
    exit 1
fi

fli sync $VS
IDOFSNAP=$(fli list -s ${SNAP} | grep ${SNAP} | head -1 | awk '{print $1}')
fli pull $VS:$IDOFSNAP
VPATH=$(fli clone $VS:$IDOFSNAP volumeFrom-$SNAP-$BUILDN)

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
