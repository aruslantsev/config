mount -o bind /dev dev
mount -o bind /proc proc
mount -o bind /sys sys
mount -o bind /run run
mount none -t tmpfs tmp
mount none -t tmpfs -o size=6144M var/tmp
mount none -t tmpfs var/cache/edb/dep
mount none -t tmpfs var/log
cp /etc/resolv.conf etc
echo Doing chroot...
echo 'Run "source /etc/profile; env-update; export PS1="(chroot) ${PS1}""'
chroot . /bin/bash
rm etc/resolv.conf
umount dev
umount sys
umount proc
umount run
umount tmp
umount var/tmp
umount var/cache/edb/dep
umount var/log


