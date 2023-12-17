echo "Check that filesystems are mounted"
echo "Mounting temporary filesystems"

# Strictly needed
mount -o bind /dev dev
mount -o bind /dev/pts dev/pts
mount -o bind /dev/shm dev/shm
mount -o bind /sys sys
mount -o bind /proc proc
mount -t tmpfs none run

# Recommended
mount -t tmpfs none var/tmp/
mount -t tmpfs -o mode=0755 none var/log/
mount -t tmpfs none tmp/

# Optional
mount -t tmpfs none var/cache/edb/dep
mount -t tmpfs none var/cache/revdep-rebuild
mount -t tmpfs none var/cache/powertop
mount -t tmpfs none usr/src
mount -t tmpfs none var/lib/dhcpcd
mount -t tmpfs none var/lib/module-rebuild
mount -t tmpfs none var/lib/upower
mount -t tmpfs none var/lib/NetworkManager
mount -t tmpfs none var/lib/bluetooth

# If we are in the livecd environment, we do not need to mount distfiles
# mount -o bind /var/cache/distfiles var/cache/distfiles

# Copy resolv.conf for working network
cp /etc/resolv.conf etc
echo Doing chroot...
echo 'Run env-update && source /etc/profile'
chroot . /bin/bash
echo Unmounting filesystems
sleep 3

# Remove created file
rm etc/resolv.conf

# Umount in reverse order

# umount var/cache/distfiles

umount var/lib/bluetooth
umount var/lib/NetworkManager
umount var/lib/upower
umount var/lib/module-rebuild
umount var/lib/dhcpcd
umount usr/src
umount var/cache/powertop
umount var/cache/revdep-rebuild
umount var/cache/edb/dep

umount tmp/
umount var/log/
umount var/tmp/

umount run
umount proc
umount sys
umount dev/shm
umount dev/pts
umount dev
