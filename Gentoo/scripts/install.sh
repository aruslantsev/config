#!/bin/bash

# Update and install necessary tools
sudo apt update
sudo apt install -y wget

# Create mount point
sudo mkdir -p /mnt/gentoo

# Download and extract the stage3 tarball
STAGE3_URL="https://distfiles.gentoo.org/releases/amd64/autobuilds/20240609T164903Z/stage3-amd64-openrc-20240609T164903Z.tar.xz"
wget ${STAGE3_URL} -O stage3.tar.xz
sudo tar --xattrs --xattrs-include='*.*' --numeric-owner -xpvf stage3.tar.xz -C /mnt/gentoo

# Mount necessary filesystems using -o bind
sudo mount -o bind /dev /mnt/gentoo/dev
sudo mount -o bind /dev/pts /mnt/gentoo/dev/pts
sudo mount -o bind /dev/shm /mnt/gentoo/dev/shm
sudo mount -o bind /sys /mnt/gentoo/sys
sudo mount -o bind /proc /mnt/gentoo/proc
sudo mount -t tmpfs none /mnt/gentoo/run

# Copy DNS info
sudo cp /etc/resolv.conf /mnt/gentoo/etc/

# Chroot into the new environment
sudo chroot /mnt/gentoo /bin/bash <<'EOF'
env-update && source /etc/profile

emaint sync -a

# Set the profile to the latest stable one
eselect profile set default/linux/amd64/23.0

# Configure locale using eselect
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
env-update && source /etc/profile

# Create and configure license acceptance file
mkdir -p /etc/portage/package.license
echo "sys-kernel/linux-firmware linux-fw-redistributable" > /etc/portage/package.license/linux-firmware

# Create and configure keyword acceptance file
mkdir -p /etc/portage/package.accept_keywords
echo "sys-kernel/linux-firmware ~amd64" > /etc/portage/package.accept_keywords/linux-firmware

# Install necessary packages
emerge sys-kernel/linux-firmware sys-kernel/gentoo-sources sys-kernel/genkernel sys-boot/grub

# Run genkernel
genkernel all

# Install and configure GRUB
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Set up the fstab
cat <<FSTAB >> /etc/fstab
# <fs>      <mountpoint> <type>  <opts>           <dump/pass>
/dev/sda1   /            ext4    noatime          0 1
/dev/sda2   none         swap    sw               0 0
FSTAB

# Set up network configuration
echo "hostname=\"gentoo\"" > /etc/conf.d/hostname

cat <<NET > /etc/conf.d/net
config_eth0="dhcp"
NET

ln -s /etc/init.d/net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default

# Set the root password
echo "root:abc123" | chpasswd

# Install necessary system tools
emerge app-admin/sysklogd
rc-update add sysklogd default
emerge net-misc/dhcpcd
rc-update add dhcpcd default

# Create a user account
useradd -m -G users,wheel,audio -s /bin/bash user
echo "user:abc123" | chpasswd

# Remind the user to change the root password after logging in: passwd
echo "Please change the root password after logging in: passwd"
EOF

# Unmount filesystems
sudo umount -l /mnt/gentoo/proc
sudo umount -l /mnt/gentoo/sys
sudo umount -l /mnt/gentoo/dev/pts
sudo umount -l /mnt/gentoo/dev/shm
sudo umount -l /mnt/gentoo/dev
sudo umount -l /mnt/gentoo/run

