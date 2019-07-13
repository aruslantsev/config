#!/bin/bash
genkernel initramfs --no-mrproper --firmware --disklabel --lvm --kernel-config=/usr/src/linux/.config --splash=tuxonice
#genkernel initramfs --no-mrproper --firmware --disklabel --kernel-config=/usr/src/linux/.config --splash=tuxonice
rm /var/tmp/genkernel/initramfs*
