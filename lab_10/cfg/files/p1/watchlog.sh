#!/bin/bash

WORD=$1
LOG=$2

if grep $WORD $LOG &> /dev/null
then
    logger "`date`: $LOG has been found"
else
    exit 0
fi
