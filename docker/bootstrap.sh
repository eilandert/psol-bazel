#!/bin/bash

set -x

dpkg-statoverride --remove /usr/bin/sudo

#apt-get update
#apt-get -y install --no-install-recommends eatmydata
#export LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}libeatmydata.so"
#export PATH=/usr/lib/ccache:${PATH}
#CCACHE_DIR=/var/cache/ccache

echo "deb [trusted=yes] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
apt-get update
apt-get -y install \
   curl \
   gnupg \
   sudo \
   apt-transport-https \
   curl \
   gnupg \
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
   curl \
   sudo \
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
   curl \
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

bazel clean --expunge
bazel fetch //pagespeed/automatic:automatic
bazel build -c fastbuild \
  @glog//:glog @com_google_absl//absl/base @com_google_absl//absl/strings @com_google_absl//absl/hash @com_google_absl//absl/memory  \
  @com_github_gflags_gflags//:gflags @com_googlesource_googleurl//base \
  //pagespeed/kernel/... //pagespeed/automatic/... //pagespeed/system/... //pagespeed/controller/... \
  //pagespeed/opt/... //base/... //net/instaweb/... //third_party/... \
  mod_pagespeed

/build.sh

cat /usr/src/nginx-${LASTVERSION}/objs/autoconf.err

dockerid=$(hostname)
echo "sleeping for 1d to allow you to use docker exec -it $dockerid bash into this docker and try some things"
echo "see /usr/src/nginx-${LASTVERSION}/objs/autoconf.err for configure errors"
sleep 1d


exit 0;

