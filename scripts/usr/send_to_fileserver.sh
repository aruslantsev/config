#!/bin/bash

rsync -avzp ${BACKUPS_PATH}/* fileserver:/srv/shares/andrei/Containers_backup
