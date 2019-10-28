#! /bin/bash

fsck /dev/sdb1 -y
mount /dev/sdb1 /mnt/chroot
cd /mnt/chroot && rm -rf ./*
debootstrap stretch /mnt/chroot
mount -t proc none /mnt/chroot/proc
mount -t sysfs none /mnt/chroot/sys
mount --bind /dev /mnt/chroot/dev

chroot /mnt/chroot ./mount.sh