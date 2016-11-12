#!/usr/bin/env bash

set -e

# This script will take a Flocker Hub endpoint, volumeset
# and snapshot as arguments and create a volume from the
# snapshot and change the `- rethink-data:` volume to
# use that snapshot.

# -------------------- Params ---------------------------------------
# VS     is a Flocker Hub Volumeset, which owns snapshots and variants
# SNAP   is a Flocker Hub Snapshot
# ENV    ci or staging?
# BRANCH uses to identify path if in staging
# --------------------- END -----------------------------------------

VS=$1
SNAP=$2
ENV=$3
BRANCH=$4

APPPATH="inventory-app/"

fli='docker run --rm --privileged -v /var/log/:/var/log/ -v /chq:/chq:shared -v /root:/root -v /lib/modules:/lib/modules clusterhq/fli'

# Check for "needed" vars
if [ -z "$VS" ]; then
    echo "VS was unset, exiting"
    exit 1
fi  

if [ -z "$SNAP" ]; then
    echo "SNAP was unset, exiting"
    exit 1
fi

if [ "${ENV}" == "staging" ]; then
    APPPATH="${BRANCH}-inventory-app/"
fi

echo "Loading the path into the application."
cat >> "${APPPATH}test-manifest.yml" <<EOL
docker_app: docker-compose.yml

flocker_hub:
  endpoint: https://data.flockerhub.clusterhq.com

volumes:
  - name: rethink-data
    snapshot: ${SNAP}
    volumeset: ${VS}
EOL

cd ${APPPATH}
/usr/local/bin/fli-docker run -f test-manifest.yml -t /root/fh.token
