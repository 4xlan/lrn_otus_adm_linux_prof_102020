#!/bin/bash

LOCKFILE_PATH=/etc/netdata/.script_lock

if [[ ! -e $LOCKFILE_PATH ]]; then
    semanage port -a -t http_port_t -p tcp 19999
    touch $LOCKFILE_PATH
fi
