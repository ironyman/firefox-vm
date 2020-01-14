#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $DIR/config.sh

if [[ ! -f $ROOT ]]; then
    $DIR/create-vm.sh
fi

if [[ ! -f $PID_FILE ]]; then
    echo Need root to start qemu.
    sudo setsid qemu-system-x86_64 \
        -drive file=${ROOT},format=raw \
        -kernel /boot/vmlinuz-`uname -r` \
        -initrd  /boot/initrd.img-`uname -r` \
        -append "root=/dev/sda rdinit=/sbin/init console=tty1,115200 console=ttyS0,115200" \
        -m ${MEMORY:-2G} \
        -smp ${CPU:-1} \
        -machine ubuntu,accel=kvm \
        -nographic \
        -device virtio-net,netdev=vmnic -netdev user,id=vmnic,hostfwd=tcp::${SSH_PORT}-:22 \
        2>&1 > /dev/null &
    disown 
    echo $! > $PID_FILE
fi

ssh-keygen -R [localhost]:5555 2>&1 >/dev/null
TRIES=10

while [[ $TRIES -gt 0 ]]; do
    sleep 10
    ssh $USER@localhost -o StrictHostKeyChecking=no -p$SSH_PORT -Y -i$KEY -q exit
    if [[ $? -eq 0 ]]; then
        break
    fi
    TRIES=$((TRIES - 1))
    echo $TRIES tries left 
done

ssh $USER@localhost -o StrictHostKeyChecking=no -p$SSH_PORT -Y -i$KEY firefox "$@"
