#!/bin/bash
useradd -m $USER
passwd -d $USER
echo LABEL=ROOT / ext4 rw 0 1 >> /etc/fstab
echo "$USER   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
systemctl enable dhclient
install -Dm 0600 -o $USER -g $USER /$KEY.pub /home/$USER/.ssh/authorized_keys
