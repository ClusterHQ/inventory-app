#!/usr/bin/env sh

# Purpose: This script installs the Fli (Fli) 
# This script is meant to be used on Ubuntu 16.04 nodes that have ZFS installed already.
# Author: Ryan Wallner

set -eu

ID=$(id -u)
if [ "$ID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if [ $# -ne 3 ]
  then
    echo "Wrong arguments supplied"
    echo "./scipt.sh DEVICE TAG HASH"
    exit 1
fi

DEVICE="$1"
TOKEN="$2"
TAG="$3"

wait() {
sleep 5
}

update_apt() {
apt-get -y update
}

command_exists() {
        command -v "$@" > /dev/null 2>&1
}

create_zfs_pool() {
apt-get -y install zfsutils-linux
echo "Running: zpool create -f -o ashift=12 -O recordsize=128k -O xattr=sa chq ${DEVICE}"
zpool create -f -o ashift=12 -O recordsize=128k -O xattr=sa chq "${DEVICE}"
}

install_start_docker() {
apt-get -y install docker.io
systemctl restart docker
}

install_docker_compose(){
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cp /usr/local/bin/docker-compose /usr/bin/
}

install_fli() {
docker login -e="." -u="clusterhq_prod+pull_fli" -p="${TOKEN}" quay.io
docker pull quay.io/clusterhq_prod/fli:${TAG}
docker tag quay.io/clusterhq_prod/fli:${TAG} clusterhq/fli
sudo echo "alias fli='docker run --rm --privileged -v /chq:/chq:shared -v /root:/root -v /lib/modules:/lib/modules clusterhq/fli'" >> /root/.bashrc
}

install_fli_docker() {
wget https://s3.amazonaws.com/ryanwallner/fli-docker-0.0.1-dev/fli-docker
chmod +x fli-docker 
mv fli-docker /usr/local/bin/
}

if [ "1" ] ; then
  echo "Installing the client software"
  update_apt
  create_zfs_pool

  # Check whether docker is installed, if not, install.
  if command_exists docker; then
     echo "Docker already installed, skipping install"
  else
     install_start_docker
     wait
  fi
  if command_exists docker-compose; then
     echo "Docker Compose already installed, skipping install"
  else
     install_docker_compose
  fi
  if command_exists fli-docker; then
     echo "Docker Compose already installed, skipping install"
  else
     install_fli_docker
  fi

  install_fli
fi

# No code is executed after the line -- some magic!

#
# Example:
#
# cat script.sh [device] [token] [hash] [customer]
#
