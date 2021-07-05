#!/bin/bash

echo Install PXE server
yum -y install epel-release

yum -y install dhcp-server
yum -y install tftp-server
yum -y install nfs-utils
firewall-cmd --add-service=tftp
# disable selinux or permissive
setenforce 0
# 

cat >/etc/dhcp/dhcpd.conf <<EOF
option space pxelinux;
option pxelinux.magic code 208 = string;
option pxelinux.configfile code 209 = text;
option pxelinux.pathprefix code 210 = text;
option pxelinux.reboottime code 211 = unsigned integer 32;
option architecture-type code 93 = unsigned integer 16;
subnet 192.168.50.0 netmask 255.255.255.0 {
	#option routers 10.0.0.254;
	range 192.168.50.100 192.168.50.120;
	class "pxeclients" {
	  match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
	  next-server 192.168.50.10;
	  if option architecture-type = 00:07 {
	    filename "uefi/shim.efi";
	    } else {
	    filename "pxelinux/pxelinux.0";
	  }
	}
}
EOF
systemctl start dhcpd
echo "DHCP done"

systemctl start tftp.service
echo "TFTP done"
yum -y install syslinux-tftpboot.noarch
mkdir /var/lib/tftpboot/pxelinux
cp /tftpboot/pxelinux.0 /var/lib/tftpboot/pxelinux
cp /tftpboot/libutil.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/menu.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/libmenu.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/ldlinux.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/vesamenu.c32 /var/lib/tftpboot/pxelinux

mkdir /var/lib/tftpboot/pxelinux/pxelinux.cfg

cat >/var/lib/tftpboot/pxelinux/pxelinux.cfg/default <<EOF
default menu
prompt 0
timeout 600
MENU TITLE Demo PXE setup
LABEL linux
  menu label ^Install system
  menu default
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img ip=enp0s3:dhcp inst.repo=nfs:192.168.50.10:/mnt/centos8-install
LABEL linux-auto
  menu label ^Auto install system
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img ip=enp0s3:dhcp inst.ks=nfs:192.168.50.10:/home/vagrant/cfg/ks.cfg inst.repo=nfs:192.168.50.10:/mnt/centos8-autoinstall
LABEL vesa
  menu label Install system with ^basic video driver
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img ip=dhcp inst.xdriver=vesa nomodeset
LABEL rescue
  menu label ^Rescue installed system
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img rescue
LABEL local
  menu label Boot from ^local drive
  localboot 0xffff
EOF

mkdir -p /var/lib/tftpboot/pxelinux/images/CentOS-8.3/
curl -O http://mirror.corbina.net/pub/Linux/centos/8.3.2011/BaseOS/x86_64/os/images/pxeboot/initrd.img
curl -O http://mirror.corbina.net/pub/Linux/centos/8.3.2011/BaseOS/x86_64/os/images/pxeboot/vmlinuz
cp {vmlinuz,initrd.img} /var/lib/tftpboot/pxelinux/images/CentOS-8.3/


# Setup NFS auto install
# 

curl -O http://mirror.corbina.net/pub/Linux/centos/8.3.2011/BaseOS/x86_64/os/images/boot.iso
mkdir /mnt/centos8-install
mount -t iso9660 -o loop boot.iso /mnt/centos8-install
echo '/mnt/centos8-install *(ro)' > /etc/exports
systemctl start nfs-server.service
echo "Done"


autoinstall(){
  # to speedup replace URL with closest mirror
  curl -O http://mirror.corbina.net/pub/Linux/centos/8.3.2011/isos/x86_64/CentOS-8.3.2011-x86_64-boot.iso
  mkdir /mnt/centos8-autoinstall
  mount -t iso9660 CentOS-8.3.2011-x86_64-boot.iso /mnt/centos8-autoinstall
  echo '/mnt/centos8-autoinstall *(ro)' >> /etc/exports
  mkdir /home/vagrant/cfg
cat > /home/vagrant/cfg/ks.cfg <<EOF
#version=RHEL8
ignoredisk --only-use=sda
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Use graphical install
graphical
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
#repo
#url --url=http://ftp.mgts.by/pub/CentOS/8.2.2004/BaseOS/x86_64/os/
# Network information
network  --bootproto=dhcp --device=enp0s3 --ipv6=auto --activate
network  --bootproto=dhcp --device=enp0s8 --onboot=off --ipv6=auto --activate
network  --hostname=localhost.localdomain
# Root password
rootpw --iscrypted $1$rmU9hJeo$6zzEz.gTS5o352BVBxBfa0
# Run the Setup Agent on first boot
firstboot --enable
# Do not configure the X Window System
skipx
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
user --groups=wheel --name=defuser --password=$1$YXD0sxi3$wB4gfHUU58YuwxVeRtI1e1 --iscrypted --gecos="defuser"
%packages
@^minimal-environment
kexec-tools
%end
%addon com_redhat_kdump --enable --reserve-mb='auto'
%end
%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
EOF
echo '/home/vagrant/cfg *(ro)' >> /etc/exports
  systemctl reload nfs-server.service
}
# uncomment to enable automatic installation
#autoinstall
