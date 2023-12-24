#!/usr/bin/env bash

HOST=$1
PORT_REMOTE=$2
PORT_LOCAL=$3
IDENTITY=$4
INTERVAL=10

if [ -z ${SSH_AGENT_PID} ]
then
	# ssh agent is not running
	KILL_AGENT=1
else
	# ssh agent is runninga
	KILL_AGENT=0
fi

if [ $KILL_AGENT -eq 1 ]
then
	trap "echo \"Caught SIGINT\"; echo \"Killing ssh-agent\"; ssh-agent -k; exit" SIGINT SIGTERM SIGKILL
else
	trap "exit"  SIGINT SIGTERM SIGKILL
fi

if [ $KILL_AGENT -eq 1 ]
then
	echo "Starting ssh-agent"
	eval $(ssh-agent)
	ssh-add ${IDENTITY}
fi

while true
do
	ssh \
		-o TCPKeepAlive=no \
		-o ExitOnForwardFailure=yes \
		-o ConnectTimeout=15 \
		-o ServerAliveInterval=30 \
		-o ServerAliveCountMax=3 \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-N -L ${PORT_LOCAL}:localhost:${PORT_REMOTE} ${HOST}
	echo Restarting...
	sleep $INTERVAL
done
