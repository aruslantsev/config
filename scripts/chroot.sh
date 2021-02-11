echo Mounting filesystems
mount -o bind /dev dev
mount -o bind /dev/pts dev/pts
mount -o bind /sys sys
mount -o bind /proc proc
mount -o bind /usr/portage/distfiles usr/portage/distfiles
mount -t tmpfs none var/tmp/
mount -t tmpfs none var/log/
mount -t tmpfs none tmp/
mount -t tmpfs none var/cache/revdep-rebuild
mount -t tmpfs none var/lib/upower
mount -t tmpfs none usr/src

cp /etc/resolv.conf etc
echo Doing chroot...
echo 'Run env-update && source /etc/profile'
chroot . /bin/bash
echo Unmounting filesystems
sleep 3
rm etc/resolv.conf

umount var/tmp/
umount var/log/
umount tmp/
umount var/cache/revdep-rebuild
umount var/lib/upower
umount usr/src
umount dev/pts
umount dev
umount sys
umount proc
umount usr/portage/distfiles

