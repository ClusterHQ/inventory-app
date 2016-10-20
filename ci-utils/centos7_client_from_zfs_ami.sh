#!/usr/bin/env sh

# Purpose: This script installs the Flocker Line Interface (fli) from Quay.io (SaaS Docker image repository)
# This script is meant to be used on CentOS 7 nodes that have ZFS installed already.
# Author: Ryan Wallner

set -eu

if [ "$EUID" -ne 0 ]
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

update_yum() {
yum -y update
}

command_exists() {
        command -v "$@" > /dev/null 2>&1
}

create_zfs_pool() {
# # Adding `cd` and `mkdir` with `zpool create -m` below 
# becuase I am getting the bellow error from the command,
# but chq pool was still created and mounted. Error was:
# ```
# cloud-init: mount: mount(2) failed: No such file or directory
# cloud-init: cannot mount 'chq': No such device or address
# ```
export PATH=$PATH:/usr/local/sbin/
echo "export PATH=$PATH:/usr/local/sbin/" >> /root/.bashrc
cd /root
mkdir /chq
echo "Running: zpool create -f -o ashift=12 -O recordsize=128k -O xattr=sa -m /chq chq ${DEVICE}"
zpool create -f -o ashift=12 -O recordsize=128k -O xattr=sa -m /chq chq "${DEVICE}"
}

install_start_docker() {
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum -y install docker-engine
service docker start
}

install_docker_compose(){
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
}

install_fli() {
docker login -e="." -u="clusterhq_prod+pull_fli" -p="${TOKEN}" quay.io
docker pull quay.io/clusterhq_prod/fli:${TAG}
docker tag quay.io/clusterhq_prod/fli:${TAG} clusterhq/fli
sudo echo "alias fli='docker run --privileged -v /chq:/chq:shared -v /root:/root -v /lib/modules:/lib/modules clusterhq/fli'" >> /root/.bashrc
}

if [ "1" ] ; then
  echo "Installing the client software"
  update_yum
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

  install_fli
fi

# No code is executed after the line -- some magic!

#
# Example:
#
# cat script.sh [device] [token] [hash] [customer]
#
