#!/usr/bin/env sh

# Purpose: This script installs the Fli
# This script is meant to be used on CentOS 7 nodes that have ZFS installed already.
# Author: Ryan Wallner

set -eu

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if [ $# -ne 1 ]
  then
    echo "Wrong arguments supplied"
    echo "./scipt.sh DEVICE"
    exit 1
fi

DEVICE="$1"

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
cp /usr/local/bin/docker-compose /usr/bin/
}

install_fli() {
docker pull clusterhq/fli
sudo echo "alias fli='docker run --rm --privileged -v /var/log/:/var/log/ -v /chq:/chq:shared -v /root:/root -v /lib/modules:/lib/modules clusterhq/fli'" >> /root/.bashrc
}

install_fli_docker() {
yum -y install wget
wget -O /usr/local/bin/fli-docker https://s3.amazonaws.com/clusterhq-fli-docker/0.2.0/fli-docker
chmod +x /usr/local/bin/fli-docker
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

  install_fli_docker
  install_fli
fi

# No code is executed after the line -- some magic!

#
# Example:
#
# cat script.sh [device] [token] [hash] [customer]
#
