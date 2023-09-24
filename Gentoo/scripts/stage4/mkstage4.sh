mount -o bind / /mnt
mount -o bind /boot /mnt/boot
cd /mnt/
tar cjpvf ~/stage4.tar.bz2 -X ~/stage4.excl .
cd
umount /mnt/boot
umount /mnt
