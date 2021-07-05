#!/bin/bash

MIN_VAL=4
RESTART_P=1
CUR_VAL=$(ip ro | wc -l)

echo -e "Checking route list."

while [ $CUR_VAL -lt $MIN_VAL ]; do
    echo "> Router still doesn't have enough routes (Detected: $CUR_VAL). Restart in $RESTART_P sec."
    sleep $RESTART_P
    systemctl restart network
    CUR_VAL=$(ip ro | wc -l)
done

echo -e "Passed: Routes added (Detected: $CUR_VAL)."
