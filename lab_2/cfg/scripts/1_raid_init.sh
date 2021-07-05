#!/bin/bash

export MDADM_CAT=/etc/mdadm
export MDADM_FIL=$MDADM_CAT/mdadm.conf

yum install -y mdadm smartmontools hdparm gdisk kernel-devel-`uname -r`


mdadm --zero-superblock --force /dev/sd{b,c,d,e} 2>/dev/null
mdadm --create /dev/md0 -l 10 --metadata=1.2 --raid-devices=4 /dev/sd{b,c,d,e}

if [ ! -d $MDADM_CAT ]; then
mkdir $MDADM_CAT
fi

echo "DEVICE partitions" > $MDADM_FIL && mdadm --detail --scan --verbose | awk '/ARRAY/{print}' >> $MDADM_FIL

parted -s /dev/md0 mklabel gpt

parted -s /dev/md0 mkpart primary ext4 0% 25%
parted -s /dev/md0 mkpart primary ext4 25% 50%
parted -s /dev/md0 mkpart primary ext4 50% 75%
parted -s /dev/md0 mkpart primary ext4 75% 100%

for i in $(seq 1 4); do mkfs.ext4 /dev/md0p$i; done

mkdir -p /raid/part{1,2,3,4}

for i in $(seq 1 4); do mount /dev/md0p$i /raid/part$i; done
