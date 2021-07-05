#!/bin/bash

WRONG_ADDR="10.0.2.2"
RESTART_P=1
CURRENT_DGW=$(ip ro | grep "default" | awk -F " " '{print $3}')

echo -e "Checking def.route."

while [ $CURRENT_DGW == $WRONG_ADDR ]; do
    echo "> Still active $WRONG_ADDR. Restart in $RESTART_P sec."
    sleep $RESTART_P
    systemctl restart network
    CURRENT_DGW=$(ip ro | grep "default" | awk -F " " '{print $3}')
done

echo -e "Passed: ETH0 defroute was supressed.\nUsing $CURRENT_DGW now."
