#!/bin/bash

cd /usr/src/master
#sed -i -r 's/sys_siglist\[signum\]/strsignal(signum)/g' third_party/apr/src/threadproc/unix/signals.c

#  --@com_googlesource_googleurl//build_config:system_icu=0 \

bazel build -c fastbuild \
  @glog//:glog \
  @com_google_absl//... \
  @com_github_gflags_gflags//... \
  @com_googlesource_googleurl//... \
  @google_sparsehash//... \
  //pagespeed/kernel/... //pagespeed/automatic/... //pagespeed/system/... //pagespeed/controller/... \
  //pagespeed/opt/... //base/... //net/instaweb/... //third_party/... \
  mod_pagespeed

cd /usr/src/master/pagespeed/automatic

ADIR=$(bazel info bazel-bin)
ALIST=$(find -L $ADIR | grep \.a$ | grep -v main | grep -v copy | grep -v envoy | grep -v testdata |grep -v _race | grep -v librewriter.a|  xargs echo)

#ALIST2="/lib/x86_64-linux-gnu/libicudata.a /lib/x86_64-linux-gnu/libicuuc.a"
#ALIST="${ALIST1} ${ALIST2}"

echo "merging libs"
./merge_libraries.sh ~/pagespeed_automatic.a.dirty $ALIST
./rename_c_symbols.sh ~/pagespeed_automatic.a.dirty ~/pagespeed_automatic.a
strip -s -S ~/pagespeed_automatic.a

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

cd /usr/src/master/pagespeed/automatic
DIR=$(bazel info output_base)
cd /usr/src/master

#GLOG
rsync -Larz "${DIR}/execroot/mod_pagespeed/bazel-out/k8-fastbuild/bin/external/glog/_virtual_includes/default_glog_headers/glog" "psol/include" \
  --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

#ABSEIL
rsync -Larz "${DIR}/external/com_google_absl/absl" "psol/include" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

#GFLAGS
rsync -Larz "${DIR}/execroot/mod_pagespeed/bazel-out/k8-fastbuild/bin/external/com_github_gflags_gflags/_virtual_includes/gflags/gflags" \
  "psol/include" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

#GURL
rsync -Larz "${DIR}/external/com_googlesource_googleurl/url" "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

#SPARSE HASH SET
rsync -Larz "${DIR}/execroot/mod_pagespeed/bazel-out/k8-fastbuild/bin/external/google_sparsehash/_virtual_includes/google_sparsehash/google" \
  "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --include="dense_hash_map" \
  --include="dense_hash_set" \
  --include="sparse_hash_map" \
  --include="sparse_hash_set" \
  --include="sparsetable" \
  --exclude='*'

#PAGESPEED
rsync -Larz "pagespeed" "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

#BASE
rsync -Larz "base" "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

rsync -Larz "net" "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

rsync -arz "third_party" "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*/' \
  --exclude='*'

cd /usr/src/master
tar czf /usr/src/psol-bazel-${DIST}.tar.gz psol

cd /usr/src
rm -rf nginx*
pip install lastversion
export LASTVERSION=$(lastversion nginx)
lastversion download nginx
tar zxvf nginx-*.tar.gz
cd nginx-${LASTVERSION}
mkdir modules
cd modules
git clone https://github.com/eilandert/pagespeed-ngx-bazel.git
cd incubator-pagespeed-ngx/
tar zxvf /usr/src/psol-bazel-${DIST}.tar.gz
cd /usr/src/nginx-${LASTVERSION}
./configure \
        --with-cc-opt='-Wformat -Werror=format-security -DNGX_HTTP_HEADERS -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -fPIC -static-libstdc++' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-pcre-jit --with-threads \
        --add-dynamic-module=modules/incubator-pagespeed-ngx
make
exit 0;

