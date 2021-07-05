#!/bin/bash

yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
yum install -y --enablerepo=elrepo-kernel kernel-ml
mv /boot/grub2/grub.cfg /boot/grub2/grub.cfg.bckp
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
