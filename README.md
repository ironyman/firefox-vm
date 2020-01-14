# Prerequisites
Requires ubuntu. 
```
apt install -y e2fsprogs coreutils debootstrap qemu-system-x86 openssh-client sudo
```

# Start firefox in vm
This will setup vm if not done yet. It will request root via sudo to do things
like mount and debootstrap and chroot.
```
./firefox-vm.sh
```

Repeated invocations of firefox-vm.sh will reuse running vm. To stop vm
```
./stop-firefox-vm.sh
```

To remove vm
```
git clean -x -d -f
```
