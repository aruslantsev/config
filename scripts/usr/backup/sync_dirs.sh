#!/bin/bash
TRANSFERS=10

for dir in Archive Backups_other Books Containers_backup Courses Documents git Manuals Pictures System_backup
do
echo ========== ${dir} ==========
rclone sync -P --transfers $TRANSFERS /srv/shares/andrei/${dir} yandex-disk-encrypted:${dir}
done

echo ========== Elena ==========
rclone sync -P --transfers $TRANSFERS /srv/shares/elena/backup yandex-disk-encrypted:Backup-Elena

# --retries 3 --low-level-retries 3
# sync -> copy
