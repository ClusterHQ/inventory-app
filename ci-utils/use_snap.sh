#!/usr/bin/env bash

# This script will take a Flocker Hub endpoint, volumeset
# and snapshot as arguments and create a volume from the
# snapshot and change the `- rethink-data:` volume to
# use that snapshot.

# -------------------- Params ---------------------------------------
# VS    is a Flocker Hub Volumeset, which owns snapshots and variants
# SNAP  is a Flocker Hub Snapshot
# EP    is the Flocker Hub URL endpoint used by the CLI.
# VPATH  is the /chq/UUID path returned by `dpcli create volume`
# --------------------- END -----------------------------------------

VS=$1
SNAP=$2
EP=$3

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
/opt/clusterhq/bin/dpcli set --vhub $EP
/opt/clusterhq/bin/dpcli sync volumeset $VS
/opt/clusterhq/bin/dpcli pull snapshot $SNAP
VPATH=$(/opt/clusterhq/bin/dpcli create volume -s $SNAP 2>&1 | grep -E -o  '\/chq\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
/usr/bin/sed -i 's@\- rethink-data:@\- '"${VPATH}"':@' inventory-app/docker-compose.yml

