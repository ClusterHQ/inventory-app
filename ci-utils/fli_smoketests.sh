#!/bin/bash

set -e
shopt -s expand_aliases

### To test properly, edit the /etc/hosts and Auth token in 
### Manage Jenkins --> Configure System --> Ubuntu 16.04 Staging Testing Nodes -->
### Advanced (under Init Script) --> User Data

function Prereq {
        ### Install the ZFS Utilities for Linux
        sudo apt install uuid zfsutils-linux -y
        echo "Installed ZFS Linux utilities"
}
## run pre-reqs
Prereq

### The ZFS Pool name can be defined by the user / customer
zpool_name='chq'

### The VolumeSet name and Volume can be defined by the user
### make volumesets and name unique so it can repeat.
volid=$(uuid)
volumeset_name="videos-$volid"
nameid=$(uuid)
volume_name="testingvol-$nameid"

### Set up the FlockerHub URL and Token File
flockerhub_tokenfile='/root/fh.token'

## Jenkins already logged in with access and downloaded clusterhq/fli-staging
## so lets test it.
docker run --rm clusterhq/fli-staging version

## Export the fli docker command for testing
## --net=host because we've changes /etc/hosts in jenkins
fli='docker run --rm --privileged --net=host -v /chq:/chq:shared -v /root:/root -v /var/log/fli:/var/log/fli -v /lib/modules:/lib/modules clusterhq/fli-staging'

### Configure the FlockerHub URL token
$fli config --token ${flockerhub_tokenfile}
echo "Set FlockerHub token to ${flockerhub_tokenfile}"

### Show me the ZFS Pools on the system
sudo zpool list

### Configure Fli to use a ZFS Pool
$fli setup --zpool ${zpool_name} --force
echo "Configured Fli with ZFS Pool named ${zpool_name}"

### Initialize a new VolumeSet
volumeset_id=`$fli init ${volumeset_name} | tr -d '\r'`
echo "Created new VolumeSet on zpool ${zpool_name} named ${volumeset_name}"

### Create a new Volume (mount point) in the VolumeSet
volume_dir=`$fli create ${volumeset_name} ${volume_name} | tr -d '\r'`
echo "Created a new Volume named ${volume_name} under VolumeSet ${volumeset_name}"
#sudo cd ${volume_dir}
echo "Volume mount point is: ${volume_dir}"

### Download some data to the Volume
file1="${volume_dir}/file1.mp4"
echo "Downloading file to: ${file1}"
wget -o $file1 http://video.ch9.ms/ch9/f9f1/8aff785c-f799-47fd-97c2-0d4f79f9f9f1/PowerShellLinuxDockerNETCoreIntro.mp4
$fli snapshot ${volumeset_name}:${volume_name} onefile

file2="${volume_dir}/file2.mp4"
echo "Downloading file to: ${file2}"
wget -o $file2 http://video.ch9.ms/ch9/f9f1/8aff785c-f799-47fd-97c2-0d4f79f9f9f1/PowerShellLinuxDockerNETCoreIntro_high.mp4
$fli snapshot ${volumeset_name}:${volume_name} twofile

file3="${volume_dir}/file3.mp4"
echo "Downloading file to: ${file3}$(tput setaf 7)"
wget -o $file3 http://video.ch9.ms/ch9/ecc5/8403d27e-a01b-4a62-8b73-8e4916f3ecc5/LearnPowerShell5UsingStatement_high.mp4
$fli snapshot ${volumeset_name}:${volume_name} threefile

file4="${volume_dir}/file4.mp4"
echo "$(tput setaf 6)Downloading file to: ${file4}$(tput setaf 7)"
wget -o ${file4} http://video.ch9.ms/ch9/7778/51420d07-ee0d-46e1-b0ca-d09350ac7778/MicrosoftAzurePowerShellExtensions20160508_high.mp4
$fli snapshot ${volumeset_name}:${volume_name} fourfile

### List out snapshots for the VolumeSet
$fli show --snapshot ${volumeset_id}:

### Sync metadata for VolumeSet with FlockerHub
echo "$(tput setaf 6)Syncing metadata for VolumeSet ${volumeset_id}$(tput setaf 7)"
$fli sync ${volumeset_id}

### Push the VolumeSet to FlockerHub
echo "$(tput setaf 6)Pushing VolumeSet to FlockerHub with ID ${volumeset_id}$(tput setaf 7)"
$fli push ${volumeset_id}

### Remove the VolumeSet from the local system
echo "$(tput setaf 6)Removing VolumeSet from the local system: ${volumeset_id}$(tput setaf 7)"
$fli remove ${volumeset_id}

### Sync VolumeSet Metadata from FlockerHub
echo "$(tput setaf 6)Syncing metadata from FlockerHub for VolumeSet ${volumeset_id}$(tput setaf 7)"
$fli sync ${volumeset_id}

### Download the entire VolumeSet onto the local system
echo "$(tput setaf 6)Downloading (pulling) VolumeSet with ID: ${volumeset_id}$(tput setaf 7)"
$fli pull ${volumeset_id}

### Clone one of the snapshots into a new Volume
$fli show --snapshot ${volumeset_id}:
echo "Now we will clone a snapshot into a new volume."
snapshot_id="onefile"
echo "$(tput setaf 6)Cloning snapshot ${snapshot_id} into a new volume$(tput setaf 7)"
cloned_volume=`$fli clone ${volumeset_id}:${snapshot_id}`
echo "The snapshot (${snapshot_id}) was successfully cloned into ${cloned_volume}"

# Clean up
$fli setup -z chq -f

echo "Test script has completed successfully"