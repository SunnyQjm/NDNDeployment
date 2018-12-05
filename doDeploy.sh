#!/bin/bash
username=$1
password=$2
ip=$3
routerName=$4
mapPort=$5

TEMP_DIR=.temp

transName=$(echo ${routerName//\//.})
transName=$(echo ${transName#.})

nbs=$(cat $TEMP_DIR/$transName.nbs)
nics=$(cat $TEMP_DIR/$transName.nics)

echo $nbs
echo $nics
