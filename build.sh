#!/bin/sh

WORKDIR=$(pwd)

mkdir -p src
cd src

DIST=focal

cd ${WORKDIR}

cp docker/Dockerfile-template docker/Dockerfile
sed -i s/DIST/${DIST}/ docker/Dockerfile

docker build --no-cache -t eilandert/psol:${DIST} docker
docker push eilandert/psol:${DIST}
docker run --volume ${WORKDIR}/src:/usr/src eilandert/psol:${DIST}
