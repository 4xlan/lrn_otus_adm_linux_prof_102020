#!/bin/sh

NGN_PATH=/usr/share/nginx/html/repo
PRC_NAME="as-repo-centos7.rpm"
PRC_URL="https://as-repository.openvpn.net/as-repo-centos7.rpm"

mkdir -p $NGN_PATH

cp /root/rpmbuild/RPMS/x86_64/$(ls -l /root/rpmbuild/RPMS/x86_64/ | awk -F " " '{print $9}' | grep nginx | grep -v debug) ${NGN_PATH}

wget ${PRC_URL} -O ${NGN_PATH}/${PRC_NAME}

cp /tmp/default.conf /etc/nginx/conf.d/default.conf

nginx -s reload

mv /tmp/test.repo /etc/yum.repos.d/test.repo

createrepo $NGN_PATH

yum install -y openvpn-as-yum
