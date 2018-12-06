#!/bin/bash
name=$1
network=$2
site=$3
router=$4

cat /dev/null > nlsr.conf
./nlsr_configs/generate-general.sh $network $site $router >> nlsr.conf
./nlsr_configs/generate-neighbour.sh $name >> nlsr.conf
./nlsr_configs/generate-hyperbolic.sh >> nlsr.conf
./nlsr_configs/generate-fib.sh >> nlsr.conf
./nlsr_configs/generate-security.sh >> nlsr.conf
