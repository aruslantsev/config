qemu-system-x86_64 \
-name Gentoo \
-enable-kvm -machine q35,accel=kvm -device intel-iommu \
-m 1024 \
-cpu host -smp 2 \
-drive file=gentoo-nas.qcow2,if=virtio \
-net user,hostfwd=tcp::10022-:22 -net nic
# -device virtio-net,netdev=vmnic -netdev user,id=vmnic

# -drive file=~/images/install-amd64-minimal-20190630T214502Z.iso,media=cdrom \
# -boot d
