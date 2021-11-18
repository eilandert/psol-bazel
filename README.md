trying to fix and build psol with bazel in docker
Please see docker/build.sh for building

How to use:

1) install docker
2) clone this repo
3) run ./build.sh

It will create a docker, installs a build environment, installs bazel,
build psol, makes a psol.tar.gz package, configures nginx and builds nginx

during this process it clones the ngx_pagespeed_module from
https://github.com/eilandert/pagespeed-ngx-bazel
