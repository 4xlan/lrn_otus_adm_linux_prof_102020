#!/bin/bash

WRONG_ADDR="10.0.2.2"
RESTART_P=5
CURRENT_DGW=$(ip ro | grep -m 1 "default" | awk -F " " '{print $3}')

echo -e "Checking def.route."

while [ $CURRENT_DGW == $WRONG_ADDR ]; do
    echo "> Still active $WRONG_ADDR. Restart in $RESTART_P sec."
    sleep $RESTART_P
    systemctl restart network >> /dev/null
    CURRENT_DGW=$(ip ro | grep -m 1 "default" | awk -F " " '{print $3}')
done

echo -e "Passed: ETH0 defroute was supressed.\nUsing $CURRENT_DGW now."
