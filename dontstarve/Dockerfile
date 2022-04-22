FROM ghcr.io/vergilgao/debian-baseimage

LABEL maintainer="VergilGao"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-steamcmd-server"

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get -y install --no-install-recommends \
		lib32gcc-s1 \
		lib32stdc++6 \
		libcurl4-gnutls-dev:i386 \
		screen && \
	rm -rf /var/lib/apt/lists/*

ENV USER=steam
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV TZ="Asia/Shanghai"

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"

ENV GAME_ID="343050"

ENV CAVES="true"

RUN mkdir $DATA_DIR && \
	mkdir $STEAMCMD_DIR && \
	mkdir $SERVER_DIR && \
	mkdir $DATA_DIR/.klei && \
	mkdir $DATA_DIR/.klei/DoNotStarveTogether && \
	useradd -d $DATA_DIR -s /bin/bash steam && \
	chown -R steam $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/docker-entrypoint.sh"]
