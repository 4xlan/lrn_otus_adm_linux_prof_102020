#/bin/bash
if [[ ! -d /raid ]]
then
    mkdir -p /raid/part{1,2,3,4}
elif not grep -qs '/raid/part1' /proc/mounts
then
    for i in $(seq 1 4); do mount /dev/md0p$i /raid/part$i; done
fi
