find /var/db/pkg/ -type d |sed s/"\/var\/db\/pkg\/"//g | grep \/ | sed s/"-[0-9].*"//g |xargs equery k
