# Prerequisites

```
apt install -y e2fsprogs coreutils debootstrap qemu-system-x86
```


# Create vm
```
sudo ./create-vm.sh

```

# Run firefox
Start vm
```
qemu-system-x86_64 \
    -drive file=root.img,format=raw \
    -kernel /boot/vmlinuz-`uname -r` \
    -initrd  /boot/initrd.img-`uname -r` \
    -append "root=/dev/sda rdinit=/sbin/init console=tty1,115200 console=ttyS0,115200" \
    -m $MEMORY \
    -smp ${CPU:-1} \
    -machine ubuntu,accel=kvm \
    -nographic \
    -device virtio-net,netdev=vmnic -netdev user,id=vmnic,hostfwd=tcp::5555-:22
```
Run firefox
```
ssh user@localhost -p5555 -Y firefox
```
