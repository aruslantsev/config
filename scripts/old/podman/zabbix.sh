#!/bin/bash

MYSQL_ZABBIX_PASSWORD=""
MYSQL_ROOT_PASSWORD=""

# create new pod with name zabbix and exposed ports (web-interface, Zabbix server trapper)

podman pod create --name zabbix \
    -p 623:623 \
    -p 3000:8080 \
    -p 10051:10051

# start Zabbix agent container in zabbix pod location:

podman run --name zabbix-agent \
    -e ZBX_SERVER_HOST="127.0.0.1,localhost" \
    --restart=always \
    --pod=zabbix \
    --memory=32m \
    --cpus=0.1 \
    -d zabbix/zabbix-agent:latest


podman run --name zabbix-server-mysql -t \
    -e DB_SERVER_HOST="192.168.88.40" \
    -e MYSQL_DATABASE="zabbix" \
    -e MYSQL_USER="zabbix" \
    -e MYSQL_PASSWORD=$MYSQL_ZABBIX_PASSWORD \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -v /srv/containers-data/zabbix/zabbix_server.conf:/etc/zabbix/zabbix_server.conf:Z \
    --restart=always \
    --pod=zabbix \
    --memory=1g \
    --cpus=1 \
    -d zabbix/zabbix-server-mysql:latest

podman run --name zabbix-web-mysql -t \
    -e ZBX_SERVER_HOST="127.0.0.1" \
    -e DB_SERVER_HOST="192.168.88.40" \
    -e MYSQL_DATABASE="zabbix" \
    -e MYSQL_USER="zabbix" \
    -e MYSQL_PASSWORD=$MYSQL_ZABBIX_PASSWORD \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    --restart=always \
    --pod=zabbix \
    --memory=1g \
    --cpus=1 \
    -d zabbix/zabbix-web-apache-mysql:latest
