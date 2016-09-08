#!/bin/sh

# This script will take a Flocker Hub endpoint, volumeset
# and snapshot as arguments and create a volume from the
# snapshot and change the `- rethink-data:` volume to
# use that snapshot.

VS=$1
SNAP=$2
EP=$3

# should always check for init, but not fail if init already done.
/opt/clusterhq/bin/dpcli init || true
/opt/clusterhq/bin/dpcli set --vhub $EP
/opt/clusterhq/bin/dpcli sync volumeset $VS
/opt/clusterhq/bin/dpcli pull snapshot $SNAP
/opt/clusterhq/bin/dpcli show snapshot -d $VS
PATH=$(sudo /opt/clusterhq/bin/dpcli create volume -s SNAP 2>&1 | grep -E -o  '\/chq\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
/usr/bin/sed 's@\- rethink-data:@\- '"${PATH}"':@' inventory-app/docker-compose.yml
