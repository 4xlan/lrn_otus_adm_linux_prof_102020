#!/bin/bash

cd /root
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-2.el7.ngx.src.rpm
rpm -i nginx-1.18.0-2.el7.ngx.src.rpm
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
yum-builddep -y rpmbuild/SPECS/nginx.spec
