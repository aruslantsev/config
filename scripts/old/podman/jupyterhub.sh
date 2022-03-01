#!/bin/bash

podman run -d --name jupyterhub \
    -p 8000:8000 \
    -v /home/andrei/:/home/andrei/:Z \
    --restart=always \
    --memory=8g \
    jupyterhub/jupyterhub jupyterhub
