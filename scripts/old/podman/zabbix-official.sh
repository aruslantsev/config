#!/bin/bash

MYSQL_PASSWORD=""
MYSQL_ROOT_PASSWORD=""

# create new pod with name zabbix and exposed ports (web-interface, Zabbix server trapper)

podman pod create --name zabbix -p 80:8080 -p 10051:10051

# start Zabbix agent container in zabbix pod location:

podman run --name zabbix-agent \
    -e ZBX_SERVER_HOST="127.0.0.1,localhost" \
    --restart=always \
    --pod=zabbix \
    -d zabbix/zabbix-agent:latest

# create /mnt/containers/mysql/ directory on host and start Oracle MySQL server 8.0:

podman run --name mysql-server -t \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
      -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
      -v /srv/containers-data/mysql/:/var/lib/mysql/:Z \
      --restart=always \
      --pod=zabbix \
      -d mysql \
      --character-set-server=utf8 --collation-server=utf8_bin \
      --default-authentication-plugin=mysql_native_password

# start Zabbix server container:

podman run --name zabbix-server-mysql -t \
                  -e DB_SERVER_HOST="127.0.0.1" \
                  -e MYSQL_DATABASE="zabbix" \
                  -e MYSQL_USER="zabbix" \
                  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
                  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
                  -e ZBX_JAVAGATEWAY="127.0.0.1" \
                  --restart=always \
                  --pod=zabbix \
                  -d zabbix/zabbix-server-mysql:latest

# start Zabbix Java Gateway container:

podman run --name zabbix-java-gateway -t \
      --restart=always \
      --pod=zabbix \
      -d zabbix/zabbix-java-gateway:latest

# start Zabbix web-interface container:

podman run --name zabbix-web-mysql -t \
                  -e ZBX_SERVER_HOST="127.0.0.1" \
                  -e DB_SERVER_HOST="127.0.0.1" \
                  -e MYSQL_DATABASE="zabbix" \
                  -e MYSQL_USER="zabbix" \
                  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
                  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
                  --restart=always \
                  --pod=zabbix \
                  -d zabbix/zabbix-web-apache-mysql:latest
