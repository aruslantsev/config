#!/bin/bash

DATE=`date +"%Y-%m-%d_%H-%M"`
PATH_PREFIX=$BACKUPS_PATH

for db_name in mediawiki zabbix
do
echo $db_name
sudo mysqldump -u root --password=$MYSQL_ROOT_PASSWORD "$db_name" > "$PATH_PREFIX"/"$DATE"-"$db_name".sql
/bin/gzip "$PATH_PREFIX"/"$DATE"-"$db_name".sql
done

# BACKUP ALL. Not very good idea because you'll be used to upload all databases
# sudo mysqldump -u root --password=$MYSQL_ROOT_PASSWORD -A > "$PATH_PREFIX"/"$DATE"-all-db.sql
# /bin/gzip "$PATH_PREFIX"/"$DATE"-all-db.sql

# Remove backups older than 30 days
/usr/bin/find "$PATH_PREFIX" -type f -mtime +30 -exec rm -rf {} \;

# How to use backup
# mysql -u root --password=$MYSQL_ROOT_PASSWORD database < database.sql
