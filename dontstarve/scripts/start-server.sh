#!/bin/bash

if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "Steamcmd not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz https://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
    chmod -R 770 $STEAMCMD_DIR  $SERVER_DIR 
fi

echo "---Update steamcmd---"
${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
    
echo "---Update server---"
${STEAMCMD_DIR}/steamcmd.sh \
    +force_install_dir $SERVER_DIR \
    +login anonymous \
    +app_update $GAME_ID \
    +quit

echo "---Prepare Server---"

files_on=0

if [ ! -d ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1 ]; then
    mkdir ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1 && cd ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1
fi

if [ ! -f ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/cluster_token.txt ]; then
    echo "---No cluster_token.txt found--"
    echo "Replace this file with your 'cluster_token.txt'" > cluster_token.txt
    files_on=1
fi

if [ ! -f ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/cluster.ini ]; then
    echo "---No cluster.ini found---"
    files_on=1
fi

if [ ! -f ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/adminlist.txt ]; then
    echo "---No adminlist.txt found, don't worry, we will create an empty adminlist.txt for you---"

fi

if [ ! -f ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/Master/server.ini ]; then
    if [ ! -d ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/Master ]; then
        mkdir ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/Master
    fi
    echo "---No server.ini found---"
    files_on=1
fi

if [ "${CAVES}" == "true" ]; then
    if [ ! -f ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/Caves/server.ini ]; then
        echo "---No Caves/server.ini found---"
        files_on=1
    elif [ ! -f ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/Caves/worldgenoverride.lua ]; then
    echo "---No Caves/server.ini found, don't worry, we will create the worldgenoverride.lua with default options---"
        echo -e "return {\n    override_enabled = true,\n    preset = \"DST_CAVE\",\n}" > ${DATA_DIR}/.klei/DoNotStarveTogether/Cluster_1/Caves/worldgenoverride.lua 
    fi
fi

if [ "$files_on" != 0 ]; then
    echo "config files missing! you can download basic server config files from https://accounts.klei.com/account/game/servers?game=DontStarveTogether, we can do nothing here, putting server into sleep mode---"
    sleep infinity
fi

chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"
    
if [ "${CAVES}" == "true" ]; then
    echo "---Checking for old logs---"
    find $SERVER_DIR -name "masterLog.*" -exec rm -f {} \;
    find $SERVER_DIR -name "cavesLog.*" -exec rm -f {} \;
    echo "---Start Server---"
    cd ${SERVER_DIR}/bin
    screen -S Master -L -Logfile $SERVER_DIR/masterLog.0 -d -m ${SERVER_DIR}/bin/dontstarve_dedicated_server_nullrenderer -shard Master
    screen -S Caves -L -Logfile $SERVER_DIR/cavesLog.0 -d -m ${SERVER_DIR}/bin/dontstarve_dedicated_server_nullrenderer -shard Caves
    sleep 2
    screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
    tail -f ${SERVER_DIR}/masterLog.0 ${SERVER_DIR}/cavesLog.0
else
    find $SERVER_DIR -name "masterLog.*" -exec rm -f {} \;
    find $SERVER_DIR -name "cavesLog.*" -exec rm -f {} \;
    echo "---Start Server---"
    cd ${SERVER_DIR}/bin
    ${SERVER_DIR}/bin/dontstarve_dedicated_server_nullrenderer -shard Master
fi
