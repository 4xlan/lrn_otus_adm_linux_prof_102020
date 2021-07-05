#!/bin/bash

PTH="/proc"
DIV=" | "

echo "PID"$DIV"TTY"$DIV"STAT"$DIV"TIME"$DIV"COMMAND"

while read -r LINE;
do
    if [[ -d $PTH"/"$LINE ]]; then
        # PID
        PID_2="$LINE"
        
        # TTY
        TTY_7=$(ls -l "$PTH/$LINE/fd" 2>/dev/null | grep "pts" | awk -F " " '{print $11}' | uniq | awk -F "/" '{print $3"/"$4}')
        
        if [[ $TTY_7 == "" ]]; then
            TTY_7="?"
        fi
        
        # STAT
        STAT_8=$(cat /proc/$LINE/status | grep "State" | awk -F " " '{print $2}')
        
        # COMMAND
        COMMAND_11=$(cat "$PTH/$LINE/cmdline" 2>/dev/null | tr '\0' '\n' )
        # In case of empty command set program name as command
        if [[ $COMMAND_11 == "" ]]; then
            COMMAND_11=$(cat "$PTH/$LINE/status" | grep "Name" | awk -F " " '{print $2}')
        fi
        
        # TIME
        TIME_10=$(cat "$PTH/$LINE/stat" 2>/dev/null | awk -F " " '{print $14+$15}')
        TIME_10_H=$(echo "$TIME_10/60" | bc)
        TIME_10_M=$(echo "$TIME_10-($TIME_10_H*60)" | bc) 
        
        echo $PID_2$DIV$TTY_7$DIV$STAT_8$DIV$TIME_10_H":"$TIME_10_M$DIV$COMMAND_11
    fi
done <<< $(ls -l $PTH | awk -F " " '{print $9}' | grep -E "[[:digit:]]{1,}" | sort)
