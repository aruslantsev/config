# podman run -it --rm --pod=local-containers mysql mysql -h mysql-server -u root -p

MYSQL_ROOT_PASSWORD=""

sudo podman run -it --rm \
                --net=host \
                mysql \
                mysql -h server.lan -u root --password=$MYSQL_ROOT_PASSWORD
