#!/bin/bash

DISK=3G
MEMORY=2G
CPU=4

truncate root.img --size ${DISK:-3G}
mkfs.ext4 root.img -L ROOT

export MOUNTPOINT=$(mktemp -d)
mount root.img $MOUNTPOINT
debootstrap --include=firefox,openssh-server,xauth --components=main,universe bionic $MOUNTPOINT
cat <<"EOF" | bash
chroot $MOUNTPOINT
useradd -m user
passwd -d user
echo LABEL=ROOT / ext4 rw 0 1 > /etc/fstab
echo "user   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

cat<<"EOF2" > /etc/systemd/system/dhclient.service
[Unit]
Description=dhclient
#After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'modprobe virtio-net; while [[ ! $( ip l | grep -e "^2:") ]]; do sleep 1; done; /sbin/dhclient -v -w'
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF2
systemctl enable dhclient

EOF

# apt doesn't find it for some reason
# sudo apt-get -o Dir=$MOUNTPOINT update
# sudo apt-get -o Dir=$MOUNTPOINT install linux-modules-`uname -r`
mkdir $MOUNTPOINT/lib/modules/
cp /lib/modules/`uname -r` $MOUNTPOINT/lib/modules/ -r
umount $MOUNTPOINT
