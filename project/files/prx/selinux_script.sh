#!/bin/bash

LOCKFILE_PATH=/etc/nginx/.script_lock

if [[ ! -e $LOCKFILE_PATH ]]; then
    semanage port -a -t http_port_t -p tcp 444
    setsebool -P httpd_can_network_connect 1
    touch $LOCKFILE_PATH
fi
