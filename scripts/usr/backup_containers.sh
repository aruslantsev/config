#!/bin/bash

DATE=`date +"%Y-%m-%d_%H-%M"`
PATH_PREFIX=$BACKUPS_PATH

CONTAINERS_PATH=/srv/

cd "$CONTAINERS_PATH"
for dir in mediawiki
do
tar -czpvf "$PATH_PREFIX"/"$DATE"-"$dir".tar.gz "$dir"
done

# Remove backups older than 30 days
/usr/bin/find "$PATH_PREFIX" -type f -mtime +30 -exec rm -rf {} \;
