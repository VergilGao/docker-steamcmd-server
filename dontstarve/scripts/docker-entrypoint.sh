#!/bin/bash

source /opt/scripts/env.sh

echo "---Setup Timezone to ${TZ}---"
echo "${TZ}" > /etc/timezone
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Taking ownership of data...---"
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}

echo "---Starting...---"
term_handler() {
	kill -SIGTERM $(pidof dontstarve_dedicated_server_nullrenderer_x64)
	wait "$killpid" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM

gosu ${USER} "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done
