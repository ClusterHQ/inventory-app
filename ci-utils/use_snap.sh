#!/usr/bin/env bash

set -e

# This script will take a Flocker Hub endpoint, volumeset
# and snapshot as arguments and create a volume from the
# snapshot and change the `- rethink-data:` volume to
# use that snapshot.

# -------------------- Params ---------------------------------------
# VS     is a Flocker Hub Volumeset, which owns snapshots and variants
# SNAP   is a Flocker Hub Snapshot
# --------------------- END -----------------------------------------

VS=$1
SNAP=$2

fli='docker run --rm --privileged -v /chq:/chq:shared -v /root:/root -v /lib/modules:/lib/modules clusterhq/fli'

# Check for "needed" vars
if [ -z "$VS" ]; then
    echo "VS was unset, exiting"
    exit 1
fi  

if [ -z "$SNAP" ]; then
    echo "SNAP was unset, exiting"
    exit 1
fi

echo "Loading the path into the application."
cat >> inventory-app/test-manifest.yml <<EOL
docker_app: docker-compose.yml

flocker_hub:
  endpoint: 
  tokenfile: /root/fh.token

volumes:
  - name: rethink-data
    snapshot: ${SNAP}
    volumeset: ${VS}
EOL

cd inventory-app/
/usr/local/bin/fli-docker run -f test-manifest.yml 
