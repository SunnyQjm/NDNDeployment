#!/bin/bash
username=$1
password=$2
ip=$3
routerName=$4
mapPort=$5
index=$6;

# 读取网络拓扑配置
json=`cat lab_topology.json`

# 保存配置列表
list=`echo $json | jq '.'`

nics=$(echo $list | jq ".[$index].nics")
nbs=$(echo $list | jq ".[$index].nics")

echo $nbs
echo $nics
