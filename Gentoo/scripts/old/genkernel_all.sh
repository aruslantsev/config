genkernel all \
	--no-clean \
	--no-mrproper \
	--kernel-config=/usr/src/linux/.config \
	--firmware \
	--lvm \
	--microcode \
	--mdadm \
	--luks
rm /var/tmp/genkernel/initramfs*
