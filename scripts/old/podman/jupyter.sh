#!/bin/bash

podman run -d --name jupyterhub \
    -p 8000:8000 \
    -v /home/andrei/jupyter/:/home/andrei/:Z \
    --restart=always \
    --memory=8g \
    jupyterhub/jupyterhub jupyterhub

podman exec -it jupyterhub pip install notebook
podman exec -it jupyterhub useradd andrei
podman exec -it jupyterhub passwd andrei
podman exec -it jupyterhub chsh -s /bin/bash andrei
podman exec -it jupyterhub apt update
podman exec -it jupyterhub apt install sudo zip unzip nano mc htop
