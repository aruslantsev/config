qemu-system-x86_64 \
-name Win10 \
-enable-kvm -machine q35,accel=kvm -device intel-iommu \
-m 4096 \
-cpu host -smp 2 \
-drive file=win10.qcow2 \
-net user,smb=~/Downloads/ \
-nic user,model=virtio-net-pci -net nic
