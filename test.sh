#! /bin/bash
mkdir /mnt/chroot
mount /dev/sdb1 /mnt/chroot
debootstrap jessie /mnt/chroot
mount -t proc none /mnt/chroot/proc
mount -t sysfs none /mnt/chroot/sys
mount --bind /dev /mnt/chroot/dev

chroot /mnt/chroot /bin/bash
cp /proc/mounts /etc/mtab
sed -i '\|^/dev/sdb1|,$!d' /etc/mtab

uuid1=$(blkid /dev/sda1 | sed -n 's/.*UUID=\"\([^\"]*\)\".*/\1/p')
uuid2=$(blkid /dev/sda2 | sed -n 's/.*UUID=\"\([^\"]*\)\".*/\1/p')

echo "UUID=${uuid1} / ext4 errors=remount-ro 0 1" >> /etc/fstab
echo "UUID=${uuid2} none swap sw 0 0" >> /etc/fstab

apt-get install openssh-server locales
apt-get install linux-image-amd64 grub2 initramfs-tools

target_file="/etc/ssh/sshd_config"
target_line="PermitRootLogin without-password"
to_replace=" PermitRootLogin yes"

sed -i "s/${target_line}/${to_replace}/g" ${target_file}

sed -i "/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\"ISCSI_INITIATOR=iqn.h1:client ISCSI_TARGET_NAME=iqn.h1:cluster ISCSI_TARGET_IP=10.230.0.1 root=UUID=e0da755a-e541-416b-b757-6f1d9e8fb075\"" lol.txt	

mkdir /etc/iscsi
touch /etc/iscsi/iscsi.initramfs
echo "InitiatorName=iqn.h1:client" > /etc/iscsi/initiatorname.iscsi
update-grub
update-initramfs -u
passwd

echo "auto lo" > etc/network/interfaces
echo "iface lo inet loopback" >> etc/network/interfaces
echo "" >> etc/network/interfaces

echo "auto enp10s0" >> etc/network/interfaces
echo "iface enp10s0 inet dhcp" >> etc/network/interfaces
echo "" >> etc/network/interfaces

echo "auto enp1s0f0" >> etc/network/interfaces
echo "iface enp1s0f0 inet dhcp" >> etc/network/interfaces
echo "" >> etc/network/interfaces