#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. $DIR/config.sh

if [[ $EUID -ne 0 ]]; then
    exec sudo /bin/bash $0 $@ --original-user $UID
fi

options=$(getopt -o ''  --long original-user: -- "$@")
eval set -- "$options"
while true; do
    case "$1" in
    --original-user)
        shift
        original_user=$1
        echo Original user was $1
        break
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

truncate $ROOT  --size ${DISK:-3G}
chown $original_user:$original_user $ROOT
mkfs.ext4 $ROOT -L ROOT

ssh-keygen -f $KEY -q -N ''
chown $original_user:$original_user $KEY $KEY.pub

MOUNTPOINT=$(mktemp -d)

mount $ROOT $MOUNTPOINT
debootstrap --include=firefox,openssh-server,xauth --variant=minbase --components=main bionic $MOUNTPOINT

cp $DIR/$KEY.pub $MOUNTPOINT/
mkdir -p $MOUNTPOINT/lib/modules/
cp /lib/modules/`uname -r` $MOUNTPOINT/lib/modules/ -r
cp $DIR/dhclient.service $MOUNTPOINT/etc/systemd/system/dhclient.service
cp $DIR/setup-guest.sh $MOUNTPOINT/

chroot $MOUNTPOINT /setup-guest.sh

umount $MOUNTPOINT
