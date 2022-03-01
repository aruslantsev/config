#!/bin/bash

find /srv/shares/andrei/Containers_backup/ -type f -mtime +30 -exec rm -rf {} \;
