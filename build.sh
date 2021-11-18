#!/bin/sh

WORKDIR=$(pwd)

mkdir -p src
cd src

if [ ! -d "master" ]; then
    echo "cloning.."
    git clone --depth=10 -c advice.detachedHead=false --recursive https://github.com/apache/incubator-pagespeed-mod.git master
    sed -i s/"#include <string>"/"#include <string>\n#include <cstdarg>"/ pagespeed/kernel/base/string.h
else
    echo "pulling.."
    cd master
    git pull --recurse-submodules
fi

DIST=focal

cd ${WORKDIR}

cp docker/Dockerfile-template docker/Dockerfile
sed -i s/DIST/${DIST}/ docker/Dockerfile

docker build --no-cache -t psol:${DIST} docker
docker run --volume ${WORKDIR}/src:/usr/src psol:${DIST}
