#!/bin/bash

HA_PASS=""
# CREATE DATABASE `homeassistant` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
# CREATE USER 'hassuser'@'%' IDENTIFIED BY '';
# GRANT ALL PRIVILEGES ON `homeassistant`.* to 'hassuser'@'%' IDENTIFIED BY '';
# FLUSH PRIVILEGES;

podman run --name homeassistant \
           --privileged \
           -p 8123:8123 \
           -v /srv/containers-data/homeassistant/:/config/:Z \
           -v /etc/localtime:/etc/localtime:ro \
           --memory=1g \
           --cpus=0.5 \
           --restart=always \
           -d homeassistant/home-assistant:latest
