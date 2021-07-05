#!/bin/bash

TMPPIDF="$(dirname "$(which "$0")")sc.pid"
INPFILE="./access.log"
TMPFILE="./access.log.tmp"
TMPIPFL="./ip.tmp"

# Start date (Day, Hour, Minute)
# DEBUG:
# Feel free to change variables below to emulate another day/hour. Be advised: in output block date will not change (there will be current date -1 hour).

SD='13'
SH='15'
SM='23'

# Original values:
#SD=$(date -d' -1 hour' +%d)
#SH=$(date -d' -1 hour' +%H)
#SM=$(date +%M)

function output_data {

    # Output block: get all lines by ip addr, take only response code, sort and count them.
    LINES=$(awk 'NF {print $1}' $TMPFILE | wc -l | awk -F " " '{print $1}')
    echo -e "\n\n=====\nRequest stats from $(date -d' -1 hour') to $(date)\n"
    echo -e "Requests in total: $LINES\n=====\n"
    while read -r line;
    do
        echo "$line: "
        # Here in awk we recognize any quoted string as one element to catch all response codes
        grep "$line" "$TMPFILE" | awk -F " " 'BEGIN {FPAT = "([^ ]+)|(\"[^\"]+\")"} {print $7}' | sort | uniq -c
        echo "---"
    done < "$TMPIPFL"
    
    echo -e "====="
}

# Setup a pid file
if ( set -o noclobber; echo "$$" > "$TMPPIDF" ) 2> /dev/null
then
    trap 'rm -f "$TMPPIDF"; exit $?' INT TERM EXIT

    echo "" > $TMPFILE
    
    # Filter by date, load data to temporary file
    while IFS= read -r line; 
    do
        LOGDAY=$(echo "$line" | grep -Eo '[[:digit:]]{2}\/[[:alpha:]]{3,}\/[[:digit:]]{4}' | awk -F "/" '{print $1}')
        read -r LOGHOUR LOGMIN <<< $(echo "$line" | awk -F " " '{print $4}' | awk -F ":" '{print $2, $3}')
        
        
        # Not so clear, but it works.
    
        if [ "$SD" -eq "$LOGDAY" ]; then
            if [ "$SH" -eq "$LOGHOUR" ] && [ "$SM" -le "$LOGMIN" ]; then
                echo "$line" >> "$TMPFILE"
            elif [ "$SH" -lt "$LOGHOUR" ]; then
                echo "$line" >> "$TMPFILE"
            fi
        elif [ $(($SD+1)) -eq "$LOGDAY" ]; then
            if [ "$SH" -gt "$LOGHOUR" ]; then
                echo "$line" >> "$TMPFILE"
            elif [ "$SH" -eq "$LOGHOUR" ] && [ "$SM" -ge "$LOGMIN" ]; then
                echo "$line" >> "$TMPFILE"
            fi
        fi
    done < $INPFILE

    # Get all unique ip addresses.
    awk -F " " '{print $1}' $TMPFILE | sort -b | uniq | awk 'NF' > $TMPIPFL
    
    # Print report
    output_data

    # Remove temporary files
    rm -f "$TMPPIDF"
    rm -f "$TMPFILE"
    rm -f "$TMPIPFL"
    trap - INT TERM EXIT
else
    "Already locked by PID: $(cat "$TMPPIDF")"
fi
