#!/bin/bash

cd /usr/src/master
#sed -i -r 's/sys_siglist\[signum\]/strsignal(signum)/g' third_party/apr/src/threadproc/unix/signals.c

cd /usr/src/master/pagespeed/automatic

ADIR=$(bazel info bazel-bin)
ALIST=$(find -L $ADIR | grep \.a$ | grep -v main | grep -v copy | grep -v envoy | grep -v testdata |grep -v _race | xargs echo)

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

cd /usr/src/master/pagespeed/automatic
DIR=$(bazel info output_base)
cd /usr/src/master


rsync -arz "third_party" "psol/include/" --prune-empty-dirs \
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

rsync -Larz "${DIR}/external/" "psol/include/" --prune-empty-dirs \
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
  --include="mod_pagespeed_console_out.cc" \
  --include="mod_pagespeed_console_css_out.cc" \
  --include="mod_pagespeed_console_html_out.cc" \
  --exclude='*'

rsync -Larz "${DIR}/execroot/mod_pagespeed/external/com_google_absl/absl" "psol/include" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

rsync -Larz "${DIR}/execroot/mod_pagespeed/bazel-out/k8-fastbuild/bin/external/glog/_virtual_includes/default_glog_headers/glog" "psol/include" \
  --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

rsync -Larz "${DIR}/execroot/mod_pagespeed/bazel-out/k8-fastbuild/bin/external/com_github_gflags_gflags/_virtual_includes/gflags/gflags" \
  "psol/include" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

rsync -Larz "${DIR}/external/google_sparsehash/src/google" "psol/include" --prune-empty-dirs \
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

rsync -Larz "pagespeed" "psol/include/" --prune-empty-dirs \
  --exclude=".svn" \
  --exclude=".git" \
  --include='*.h' \
  --include='*.inc' \
  --include='*/' \
  --exclude='*'

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



cd /usr/src/master
tar czf /usr/src/psol-bazel-${DIST}.tar.gz psol

cd /usr/src
rm -rf nginx*
pip install lastversion
LASTVERSION=$(lastversion nginx)
lastversion download nginx
tar zxvf nginx-*.tar.gz
cd nginx-${LASTVERSION}/src
git clone https://github.com/apache/incubator-pagespeed-ngx
cd incubator-pagespeed-ngx/
tar zxvf /usr/src/psol-bazel-${DIST}.tar.gz
cd /usr/src/nginx-${LASTVERSION}
./configure --add-dynamic-module=src/incubator-pagespeed-ngx/

exit 0;

