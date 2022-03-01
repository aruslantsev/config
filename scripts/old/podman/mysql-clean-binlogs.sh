MYSQL_ROOT_PASSWORD=""

sudo podman run -it --rm \
                --net=host \
                mysql \
                    mysql \
                    -h server.lan \
                    -u root \
                    --password=$MYSQL_ROOT_PASSWORD \
                    -e "PURGE MASTER LOGS BEFORE DATE(NOW() - INTERVAL 1 DAY) + INTERVAL 0 SECOND;"
# PURGE BINARY LOGS
