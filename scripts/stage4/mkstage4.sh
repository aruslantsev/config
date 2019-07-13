mount /dev/mapper/hd-root /mnt/gentoo
mount /dev/sda1 /mnt/gentoo/boot
mount /dev/mapper/hd-var /mnt/gentoo/var
mount /dev/mapper/hd-tmp /mnt/gentoo/tmp
mount /dev/mapper/hd-usr /mnt/gentoo/usr
mount /dev/mapper/hd-vartmp /mnt/gentoo/var/tmp
cd /mnt/gentoo
tar cjpvf ~/stage4.tar.bz2 . -X ~/stage4.excl
cd
umount /dev/mapper/hd-vartmp
umount /dev/mapper/hd-var
umount /dev/mapper/hd-tmp
umount /dev/mapper/hd-usr
umount /dev/sda1
umount /dev/mapper/hd-root
