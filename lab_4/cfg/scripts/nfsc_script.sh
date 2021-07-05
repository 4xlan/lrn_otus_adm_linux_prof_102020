#!/bin/bash

mv /tmp/mnt-share.mount /etc/systemd/system/mnt-share.mount
systemctl daemon-reload
systemctl enable --now /etc/systemd/system/mnt-share.mount
