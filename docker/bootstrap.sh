#!/bin/bash

set -x

dpkg-statoverride --remove /usr/bin/sudo

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

sudo service memcached start
sudo service redis-server start

sudo apt-get update && sudo apt-get -y full-upgrade
sudo ln -s /usr/bin/bazel-4.1.0 /usr/bin/bazel

cd /usr/src/master
sudo install/install_required_packages.sh --additional_dev_packages

rm /usr/bin/python
ln -s /usr/bin/python2 /usr/bin/python

apt-get -y -t ${DIST}-backports upgrade

NUMCORE=$(cat /proc/cpuinfo | grep -c cores)
export NUMCORE
echo "NUMBER OF CORES: ${NUMCORE}"

cd /usr/src/master
#sed -i -r 's/sys_siglist\[signum\]/strsignal(signum)/g' third_party/apr/src/threadproc/unix/signals.c

#bazel clean
#bazel fetch //pagespeed/automatic:automatic
bazel build -c opt //pagespeed/automatic:automatic --verbose_failures --sandbox_debug

cd /usr/src/master/pagespeed/automatic

ADIR=$(bazel info output_base)
ALIST=$(find -L $ADIR/execroot -name "*.a" | grep -v main | grep -v copy |grep -v go_sdk|grep -v envoy| sed -e s/"^\."/"\/root"/g | xargs echo)

echo "merging libs"
./merge_libraries.sh ~/pagespeed_automatic.a.dirty $ALIST
./rename_c_symbols.sh ~/pagespeed_automatic.a.dirty ~/pagespeed_automatic.a

cd /usr/src/master
rm -rf psol
mkdir -p psol/include

if [ "$(uname -m)" = x86_64 ]; then
  bit_size_name=x64
else
  bit_size_name=ia32
fi

bindir="psol/lib/Release/linux/$bit_size_name"
mkdir -p "$bindir"
echo Copying files to psol directory...
cp -f ~/pagespeed_automatic.a $bindir/

rsync -arz "." "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*/' \
  --include="apr_thread_compatible_pool.cc" \
  --include="serf_url_async_fetcher.cc" \
  --include="apr_mem_cache.cc" \
  --include="key_value_codec.cc" \
  --include="apr_memcache2.c" \
  --include="loopback_route_fetcher.cc" \
  --include="add_headers_fetcher.cc" \
  --include="console_css_out.cc" \
  --include="console_out.cc" \
  --include="dense_hash_map" \
  --include="dense_hash_set" \
  --include="sparse_hash_map" \
  --include="sparse_hash_set" \
  --include="sparsetable" \
  --include="mod_pagespeed_console_out.cc" \
  --include="mod_pagespeed_console_css_out.cc" \
  --include="mod_pagespeed_console_html_out.cc" \
  --exclude='*'

cd /usr/src/master/pagespeed/automatic
DIR=$(bazel info output_base)
cd /usr/src/master

#
# Trying to fix:
#
#----------------------------------------
#checking for psol
#
#In file included from /build/nginx-1.21.3/debian/modules/ngx_pagespeed/psol/include/pagespeed/kernel/base/string_writer.h:25,
#                 from objs/autotest.cc:6:
#/build/nginx-1.21.3/debian/modules/ngx_pagespeed/psol/include/pagespeed/kernel/base/string_util.h:32:10: fatal error: absl/strings/internal/memutil.h: No such file or directory/internal/memutil.h"  // StripAsciiWhitespace
#      |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#compilation terminated.
#----------

rsync -arz ${DIR}/execroot/mod_pagespeed/external/com_google_absl/absl /usr/src/master/psol/include \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*/' \
  --exclude='*'

cd /usr/src/master
tar czf /usr/src/psol-bazel-${DIST}.tar.gz psol

echo "sleeping for 3h to allow you to docker exec -it into this docker and try some things"
sleep 3h

exit 0;

