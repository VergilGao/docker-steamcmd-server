#!/bin/bash

source /opt/scripts/env.sh

killpid="$(pidof dontstarve_dedicated_server_nullrenderer)"
while true
do
	tail --pid=${killpid%% *} --pid=${killpid##* } -f /dev/null
	kill "$(pidof tail)"
	exit 0
done