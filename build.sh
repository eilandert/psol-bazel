#!/bin/sh

WORKDIR=$(pwd)

mkdir -p src
cd src

#if [ ! -d "master" ]; then
#    echo "cloning.."
#    git clone -b latest-stable --depth=1 -c advice.detachedHead=false --recursive https://github.com/apache/incubator-pagespeed-mod.git
#else
#    echo "pulling.."
#    cd incubator-pagespeed-mod
#    git pull --recurse-submodules
#fi

if [ ! -d "master" ]; then
    echo "cloning.."
    git clone --depth=10 -c advice.detachedHead=false --recursive https://github.com/apache/incubator-pagespeed-mod.git master
    sed -i '1s/^/#include <cstdarg>\n/' pagespeed/kernel/base/string_util.cc
else
    echo "pulling.."
    cd master
    git pull --recurse-submodules
fi

cd ${WORKDIR}/src/master



#echo "copying third_party for now"
#cp -rp incubator-pagespeed-mod/third_party master

# add #include <cstdarg>
sed -i s/"#include <string>"/"#include <string>\n#include <cstdarg>"/ pagespeed/kernel/base/string.h

DIST=focal

cd ${WORKDIR}

cp docker/Dockerfile-template docker/Dockerfile
sed -i s/DIST/${DIST}/ docker/Dockerfile

docker build --no-cache -t eilandert/psol:${DIST} docker
#docker push eilandert/psol:${DIST}
docker run --volume ${WORKDIR}/src:/usr/src eilandert/psol:${DIST}

