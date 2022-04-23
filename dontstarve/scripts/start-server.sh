#!/bin/bash

source /opt/scripts/env.sh

if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    echo "steamcmd not found!"
    wget -q -O "${STEAMCMD_DIR}/steamcmd_linux.tar.gz" https://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory "${STEAMCMD_DIR}" -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm "${STEAMCMD_DIR}/steamcmd_linux.tar.gz"
    chmod -R 770 "$STEAMCMD_DIR"  "$SERVER_DIR"
fi

echo "---Update steamcmd---"
"${STEAMCMD_DIR}/steamcmd.sh" \
    +login anonymous \
    +quit
    
echo "---Update server---"
"${STEAMCMD_DIR}/steamcmd.sh" \
    +force_install_dir "$SERVER_DIR" \
    +login anonymous \
    +app_update $GAME_ID \
    +quit

echo "---Prepare Server---"

file_check=0

if [ ! -d "${CLUSTER_PATH}" ]; then
    mkdir "${CLUSTER_PATH}"
fi

cd "${CLUSTER_PATH}"

if [ ! -f "${CLUSTER_PATH}/cluster_token.txt" ]; then
    echo "---No cluster_token.txt found--"
    echo "Replace this file with your 'cluster_token.txt'" > cluster_token.txt
    file_check=1
fi

if [ ! -f "${CLUSTER_PATH}/cluster.ini" ]; then
    echo "---No cluster.ini found---"
    file_check=1
fi

if [ ! -f "${CLUSTER_PATH}/adminlist.txt" ]; then
    echo "---No adminlist.txt found, don't worry, we will create an empty adminlist.txt for you---"
    echo "" > adminlist.txt
fi

if [ ! -f "${CLUSTER_PATH}/Master/server.ini" ]; then
    if [ ! -d "${CLUSTER_PATH}/Master" ]; then
        mkdir "${CLUSTER_PATH}/Master"
    fi
    echo "---No server.ini found---"
    file_check=1
fi

if [ "${CAVES}" == "true" ]; then
    if [ ! -f "${CLUSTER_PATH}/Caves/server.ini" ]; then
        if [ ! -d "${CLUSTER_PATH}/Caves" ]; then
            mkdir "${CLUSTER_PATH}/Caves"
        fi
        echo "---No Caves/server.ini found---"
        file_check=1
    fi
fi

if [ "$file_check" != 0 ]; then
    echo "[ERROR] config files missing! you can download basic server config files from https://accounts.klei.com/account/game/servers?game=DontStarveTogether"
    echo "we can do nothing here, putting server into sleep mode..."
    sleep infinity
fi

chmod -R ${DATA_PERM} ${DATA_DIR}
cd ${SERVER_DIR}/bin

echo "---Server ready---"
    
if [ "${CAVES}" == "true" ]; then
    echo "---Checking for old logs---"
    find "${SERVER_DIR}" -name "masterLog.*" -exec rm -f {} \;
    find "${SERVER_DIR}" -name "cavesLog.*" -exec rm -f {} \;
    echo "---Start Server---"
    screen -S Master -L -Logfile "${SERVER_DIR}/masterLog.0" -d -m "${SERVER_DIR}/bin/dontstarve_dedicated_server_nullrenderer" -cluster "${CLUSTER_NAME}" -shard Master
    screen -S Caves -L -Logfile "${SERVER_DIR}/cavesLog.0" -d -m "${SERVER_DIR}/bin/dontstarve_dedicated_server_nullrenderer" -cluster "${CLUSTER_NAME}" -shard Caves
    sleep 2
    screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
    tail -f "${SERVER_DIR}/masterLog.0" "${SERVER_DIR}/cavesLog.0"
else
    find "${SERVER_DIR}" -name "masterLog.*" -exec rm -f {} \;
    find "${SERVER_DIR}" -name "cavesLog.*" -exec rm -f {} \;
    echo "---Start Server---"
    "${SERVER_DIR}/bin/dontstarve_dedicated_server_nullrenderer" -cluster "${CLUSTER_NAME}" -shard Master
fi
