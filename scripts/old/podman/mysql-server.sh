#!/bin/bash

MYSQL_ROOT_PASSWORD=""

podman run --name mysql-server -t \
      -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
      -v /srv/containers-data/mysql/:/var/lib/mysql/:Z \
      --restart=always \
      --net=host \
      --memory=2g \
      --cpus=0.5 \
      -d mysql:latest \
      --character-set-server=utf8 --collation-server=utf8_bin \
      --default-authentication-plugin=mysql_native_password

