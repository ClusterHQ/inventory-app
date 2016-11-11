#!/usr/bin/env sh

# Purpose: This script installs the Fli
# This script is meant to be used on CentOS 7 nodes that don't have ZFS installed.
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

EPELRELEASEURL="http://epel.mirror.net.in/epel/7/x86_64/e/epel-release-7-8.noarch.rpm"
EPELRELEASE="epel-release-7-8.noarch.rpm"
ZFSRELEASEURL="http://archive.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm"
ZFSRELEASE="zfs-release.el7.noarch.rpm"

wait() {
sleep 5
}

update_yum() {
yum -y update
}

install_wget() {
yum -y install wget
}

command_exists() {
        command -v "$@" > /dev/null 2>&1
}

install_zfs(){
wget --tries=20 --waitretry=5 ${EPELRELEASEURL} 
yum -y localinstall ${EPELRELEASE} 
wget --tries=20 --waitretry=5 ${ZFSRELEASEURL} 
yum -y localinstall ${ZFSRELEASE} 
yum -y install "kernel-devel-uname-r == $(uname -r)"
yum -y install zfs
modprobe zfs
}

create_zfs_pool() {
zpool create -f -o ashift=12 -O recordsize=128k -O xattr=sa chq ${DEVICE}
### Allow non root to zfs/zpool list
chmod 777 /dev/zfs
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
  install_wget
  install_zfs
  wait
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
# cat ready_client_cntos7.sh [device] [token] [hash] [customer]
#
