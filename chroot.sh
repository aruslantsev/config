mount -o bind /dev dev
mount -o bind /dev/pts dev/pts
mount -o bind /proc proc
mount -o bind /sys sys
mount -o bind /run run
# mount -o bind /var/cache/revdep-rebuild var/cache/revdep-rebuild
# mount -o bind /var/lib/upower var/lib/upower
mount none -t tmpfs tmp
mount none -t tmpfs -o size=6144M var/tmp
mount none -t tmpfs var/cache/edb/dep
mount none -t tmpfs var/log
cp /etc/resolv.conf etc
echo Doing chroot...
echo 'Run "source /etc/profile; env-update; export PS1="(chroot) ${PS1}""'
chroot . /bin/bash
sleep 3
rm etc/resolv.conf
umount dev/pts
umount dev
umount sys
umount proc
umount run
umount tmp
umount var/tmp
umount var/cache/edb/dep
umount var/log
# umount var/cache/revdep-rebuild
# umount var/lib/upower
