# inspired by linuxserver.io
FROM scratch
ADD alpine-minirootfs-3.6.2-armhf.tar.gz /

MAINTAINER offtechnologies <https://github.com/offtechnologies/>

# set version for s6 overlay
ARG OVERLAY_VERSION="v1.21.1.1"
ARG OVERLAY_ARCH="armhf"

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)$" \
HOME="/root" \
TERM="xterm"

# install packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	tar && \
  apk add --no-cache \
	bash \
	ca-certificates \
	coreutils \
	shadow \
	tzdata && \

# add s6 overlay
 curl -o \
 /tmp/s6-overlay.tar.gz -L \
	"https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
 tar xfz \
	/tmp/s6-overlay.tar.gz -C / && \

# create offtech user
 groupmod -g 1000 users && \
 useradd -u 912 -U -d /config -s /bin/false offtech && \
 usermod -G users offtech && \

# create folders
 mkdir -p \
	/app \
	/config \
	/defaults && \

# clean up
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /

ENTRYPOINT ["/init"]
