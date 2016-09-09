#!/usr/bin/env sh

# Meant to be run on nodes that have ZFS installed already

set -eu

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if [ $# -ne 4 ]
  then
    echo "Wrong arguments supplied"
    echo "./scipt.sh DEVICE TAG HASH CUSTOMER"
    exit 1
fi

DEVICE="$1"
TOKEN="$2"
TAG="$3"
# Matches $CUST_pull_dpcli robot in quay.io
CUST="$4"

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
cd /root
mkdir /chq
echo "Running: zpool create -f -o ashift=12 -O recordsize=128k -O xattr=sa -m /chq chq ${DEVICE}"
zpool create -f -o ashift=12 -O recordsize=128k -O xattr=sa -m /chq chq "${DEVICE}"
echo "Running: zfs snapshot chq@empty"
zfs snapshot chq@empty
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

install_dpcli() {
docker login -e="." -u="clusterhq_prod+${CUST}_pull_dpcli" -p="${TOKEN}" quay.io
docker pull quay.io/clusterhq_prod/dpcli-rpm:${TAG}
docker create --name dpcli quay.io/clusterhq_prod/dpcli-rpm:${TAG}
docker cp dpcli:/opt/clusterhq/lib/dpcli-0.0.1-1.el7.centos.x86_64.rpm .
rpm -Uvh dpcli-0.0.1-1.el7.centos.x86_64.rpm
}

install_bash_completion() {
yum -y install bash-completion
mkdir /etc/bashcompletion.d
/opt/clusterhq/bin/dpcli completion --output=/etc/bashcompletion.d/dpcli 
echo "source /etc/bashcompletion.d/dpcli" >> /root/.bashrc
echo "export PATH=$PATH:/opt/clusterhq/bin" >> /root/.bash_profile
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

  install_dpcli
  install_bash_completion
fi

# No code is executed after the line -- some magic!

#
# Example:
#
# cat script.sh [device] [token] [hash] [customer]
#
