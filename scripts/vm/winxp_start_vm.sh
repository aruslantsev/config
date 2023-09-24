qemu-system-x86_64 \
-name WinXP \
-enable-kvm -machine pc-i440fx-7.2,accel=kvm \
-m 512 \
-cpu host -smp 1 \
-drive file=winxp.qcow2 \
-netdev user,id=n0,smb=~/Downloads/ -device rtl8139,netdev=n0

# -drive file=~/images/winxp/ru_win_xp_pro_with_sp2_vl.iso,media=cdrom \
# -boot d
