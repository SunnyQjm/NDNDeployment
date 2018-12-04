#!/bin/bash

command=$1
DEBUG=0

# 读取网络拓扑配置
json=`cat lab_topology.json`

# 保存配置列表
list=`echo $json | jq '.'`

# 获取网络拓扑的节点个数
length=`echo $json | jq '.|length'` 
length=$(( $length - 1 ))
##########################################
### 具体执行部署到一个节点的操作
### @param routerName           路由节点的完整名字
### @param network
### @param site
### @param router
### @param mapPort
### @param ip
### @param username
### @param password
### @param nics 
### @param nbs
###########################################
function deal(){
    index=$1

    routerName=$(echo $list | jq -r ".[$index].name")
    network=$(echo $list | jq -r ".[$index].network")
    site=$(echo $list | jq -r ".[$index].site")
    router=$(echo $list | jq -r ".[$index].router")
    mapPort=$(echo $list | jq -r ".[$index].mapPort")
    ip=$(echo $list | jq -r ".[$index].ip")
    username=$(echo $list | jq -r ".[$index].username")
    password=$(echo $list | jq -r ".[$index].password")

    nics=$(echo $list | jq ".[$index].nics")
    nbs=$(echo $list | jq  ".[$index].nbs")
    #deal $routerName $network $site $router $mapPort $ip $username $password $nics $nbs &
 
    echo "=======================开始处理$routerName==============="
    if [ $DEBUG -eq 1 ]; then
     echo 
     echo routerName: $routerName
     echo network: $network
     echo site: $site
     echo router: $router
     echo mapPort: $mapPort
     echo ip: $ip
     echo username: $username
     echo password: $password
     echo nics: 
     echo $nics | jq '.'
     echo nbs:
     echo $nbs | jq '.'
     echo 
    fi

    case $command in
    "deploy")
        ./deploy_nfd.sh
        ;;
    "update")
        ./update.sh $username $password $ip $routerName $mapPort
        ;;
    "clone")
        ./clone.sh $username $password $ip $routerName $mapPort
        ;;
    "kill")
        ./doKill.sh $username $password $ip $routerName $mapPort
    esac
    echo "========================================================="
}



for index in `seq 0 $length`
do
    # 获取到路由的名字
    echo
    deal $index  
    echo
done
