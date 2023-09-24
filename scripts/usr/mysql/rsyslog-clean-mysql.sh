#!/bin/bash

mysql -u root -e "DELETE FROM Syslog.SystemEvents WHERE ReceivedAt < DATE(NOW() - INTERVAL 1 WEEK);"
