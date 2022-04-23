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
if [ ! -d "${SERVER_DIR}/.steam/sdk64" ]; then
  mkdir -p "${SERVER_DIR}/.steam/sdk64"
fi
if [ ! -f "${SERVER_DIR}/.steam/sdk64/steamclient.so" ]; then
  cp "${STEAMCMD_DIR}/linux64/steamclient.so" "${SERVER_DIR}/.steam/sdk64/steamclient.so"
fi

chmod -R ${DATA_PERM} ${DATA_DIR}
cd "${SERVER_DIR}/Engine/Binaries/Linux"

echo "---Server ready---"
    
exec ./UE4Server-Linux-Shipping FactoryGame $GAME_PARAMS
