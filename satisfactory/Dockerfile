FROM ghcr.io/vergilgao/debian-baseimage

LABEL maintainer="VergilGao"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-steamcmd-server"

RUN apt-get update && \
	apt-get -y install --no-install-recommends \
		lib32gcc-s1 \
		lib32stdc++6 \
		libcurl4-gnutls-dev \
		screen && \
	rm -rf /var/lib/apt/lists/*
    
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV TZ="Asia/Shanghai"

ENV GAME_ID="1690800"
ENV GAME_PARAMS=""

RUN mkdir /serverdata && \
	mkdir /serverdata/steamcmd && \
	mkdir /serverdata/serverfiles && \
	useradd -d /serverdata -s /bin/bash steam && \
	chown -R steam /serverdata && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

VOLUME [ "/serverdata/steamcmd" ]
VOLUME [ "/serverdata/serverfiles" ]

#Server Start
ENTRYPOINT ["/opt/scripts/docker-entrypoint.sh"]