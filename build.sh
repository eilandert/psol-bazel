#!/bin/sh

WORKDIR=$(pwd)

mkdir -p src
cd src
if [ ! -d "master" ]; then
    echo "cloning.."
    #    git clone -b latest-stable --depth=1 -c advice.detachedHead=false --recursive https://github.com/apache/incubator-pagespeed-mod.git
    git clone --depth=10 -c advice.detachedHead=false --recursive https://github.com/apache/incubator-pagespeed-mod.git master
else
    echo "pulling.."
    #    cd incubator-pagespeed-mod
    cd master
    git pull --recurse-submodules
fi

# add #include <cstdarg>
sed -i s/"#include <string>"/"#include <string>\n#include <cstdarg>"/ pagespeed/kernel/base/string.h


DIST=focal

cd ${WORKDIR}

cp docker/Dockerfile-template docker/Dockerfile
sed -i s/DIST/${DIST}/ docker/Dockerfile

docker build --no-cache -t eilandert/psol:${DIST} docker
#docker push eilandert/psol:${DIST}
docker run --volume ${WORKDIR}/src:/usr/src eilandert/psol:${DIST}
