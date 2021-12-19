#!/bin/bash


if [ -z "$1" ]
then
        HOST="oracle-ssh-gw"
else
        HOST=$1
fi

if [ -z "$2" ]
then
        PORT=10022
else
        PORT=$2
fi

if [ -z "$3" ]
then
        INTERVAL=300
else
        INTERVAL=$3
fi

CMD1="ssh -f -N -R ${PORT}:localhost:22 ${HOST}"

echo "Executing $CMD1, refresh interval: $INTERVAL seconds"

trap "echo \"Caught SIGINT\"; pgrep -f \"$CMD1\" | xargs kill; exit" SIGINT

while true
do
        pgrep -f "$CMD1" &>/dev/null && echo "$(date +'%Y.%m.%d %H:%M:%S'): OK" || ( echo "$(date +'%Y.%m.%d %H:%M:%S'): Reconnecting..."; $CMD1 & )
        sleep $INTERVAL
done

# on ssh-gw ssh -p 10022 USER@localhost 
