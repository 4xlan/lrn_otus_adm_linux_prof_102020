#!/bin/bash

cd /root
mv /tmp/spec /root/rpmbuild/SPECS/nginx.spec
rpmbuild -bb rpmbuild/SPECS/nginx.spec
ls -l rpmbuild/RPMS/x86_64/
yum localinstall -y /root/rpmbuild/RPMS/x86_64/$(ls -l /root/rpmbuild/RPMS/x86_64/ | awk -F " " '{print $9}' | grep nginx | grep -v debug)
systemctl enable --now nginx
