#!/bin/bash
name=$1
network=$2
site=$3
router=$4

cat /dev/null > nlsr.conf
./generate-general.sh $network $site $router >> nlsr.conf
./generate-neighbour.sh $name >> nlsr.conf
./generate-hyperbolic.sh >> nlsr.conf
./generate-fib.sh >> nlsr.conf
./generate-security.sh >> nlsr.conf
