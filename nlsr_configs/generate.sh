#!/bin/bash
name=$1
path=$2

routerName=$(echo ${name#/ndn/edu/pkusz})
cat /dev/null > nlsr.conf
./nlsr_configs/generate-general.sh /ndn /edu/pkusz $routerName >> nlsr.conf
./nlsr_configs/generate-neighbour.sh $name $path >> nlsr.conf
./nlsr_configs/generate-hyperbolic.sh >> nlsr.conf
./nlsr_configs/generate-fib.sh >> nlsr.conf
./nlsr_configs/generate-security.sh >> nlsr.conf
