FROM    eilandert/ubuntu-base:focal
LABEL   maintainer="Thijs Eilander <eilander@myguard.nl>"
ENV     DEBIAN_FRONTEND="noninteractive"
ENV     TZ=Europe/Amsterdam

COPY bootstrap.sh /bootstrap.sh
COPY build.sh /build.sh

RUN	chmod +x /bootstrap.sh

CMD     ["/bootstrap.sh"]

WORKDIR /usr/src
