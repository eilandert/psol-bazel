#!/bin/bash

dpkg-statoverride --remove /usr/bin/sudo
echo "deb [trusted=yes] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
apt-get update
apt-get -y install \
    nano \
    vim \
    sudo \
    curl \
    gnupg \
    sudo \
    apt-transport-https \
    apt \
    git \
    lsb-release \
    libpcre3-dev \
    build-essential \
    unzip \
    uuid-dev \
    webp \
    g++ \
    libssl-dev \
    wget \
    rsync \
    gperf \
    zip \
    cmake \
    ninja-build \
    zlib1g-dev  \
    icu-devtools \
    libicu-dev \
    autoconf \
    automake \
    cmake \
    libtool \
    make \
    ninja-build \
    patch \
    python3-pip \
    unzip \
    virtualenv \
    llvm \
    clang \
    bazel \
    bazel-4.1.0 \
    python2-minimal \
    openjdk-11-jdk \
    pkg-config zip g++ zlib1g-dev unzip python3 ninja-build cmake gperf memcached apache2-dev python2 clang-10 memcached redis-server

cd /usr/src
if [ ! -d "master" ]; then
    echo "cloning.."
    git clone --depth=10 -c advice.detachedHead=false --recursive https://github.com/apache/incubator-pagespeed-mod.git master
    cd master
    sed -i s/"#include <string>"/"#include <string>\n#include <cstdarg>"/ pagespeed/kernel/base/string.h
else
    echo "pulling.."
    cd master
    git pull --recurse-submodules
fi

cd /usr/src/master
sudo install/install_required_packages.sh --additional_dev_packages

sudo apt-get update && sudo apt-get -y full-upgrade
sudo ln -s /usr/bin/bazel-4.1.0 /usr/bin/bazel

rm -f /usr/bin/python
ln -s /usr/bin/python2 /usr/bin/python

NUMCORE=$(cat /proc/cpuinfo | grep -c cores)
export NUMCORE
echo "NUMBER OF CORES: ${NUMCORE}"

cd /usr/src/master
#sed -i -r 's/sys_siglist\[signum\]/strsignal(signum)/g' third_party/apr/src/threadproc/unix/signals.c

rm -rf /usr/src/nginx*

bazel clean --expunge
bazel fetch //pagespeed/automatic:automatic

/build.sh

dockerid=$(hostname)
echo "---"
echo "sleeping for 1d to allow you to use docker exec -it $dockerid bash into this docker and try some things"
sleep 1d

exit 0;

