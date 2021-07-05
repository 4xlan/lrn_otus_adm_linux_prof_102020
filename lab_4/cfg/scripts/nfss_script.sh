#!/bin/bash

yum install -y nfs-utils
systemctl enable --now firewalld
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=nfs3
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload

AG=`grep nobody /etc/passwd | awk -F : '{print $4}'`
AU=`grep nobody /etc/passwd | awk -F : '{print $3}'`
NFS_PATH=/srv/nfs/share
NFS_PATH_UPLOAD=$NFS_PATH/upload

mkdir -p $NFS_PATH_UPLOAD

echo "$NFS_PATH *(rw,async,all_squash,anonuid=$AU,anongid=$AG)" >> /etc/exports
sed -i 's|^\[nfsd\]|\[nfsd\]\nudp=y\ntcp=y\nvers4=y\nvers3=y|g' /etc/nfs.conf  

chown -R nobody:nobody $NFS_PATH
chmod 555 $NFS_PATH
chmod 777 $NFS_PATH_UPLOAD

exportfs -ra

systemctl enable --now rpcbind
systemctl enable --now nfs-server
