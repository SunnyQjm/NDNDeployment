#!/bin/bash

command=$1
ASYNC=$2
DEBUG=0
COUNT=0

if [ ! -n "$ASYNC" ]; then
    ASYNC=0
fi

# 读取网络拓扑配置
json=`cat lab_topology.json`

# 保存配置列表
list=`echo $json | jq '.'`

# 获取网络拓扑的节点个数
length=`echo $json | jq '.|length'` 
length=$(( $length - 1 ))

##########################################
### 确保一个文件夹存在，不存在则创建
### @param dir
##########################################
function ensureDir() {
    dir=$1
    if [ ! -d "$dir" ]; then
        echo "文件夹${dir}不存在，正在创建"
        mkdir -p $dir
    fi
}

# 创建temp文件夹存放中转数据
ensureDir ./temp

# TEMP_DIR=./temp

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

    # transName=$(echo ${routerName//\//.})
    # transName=$(echo ${transName#.})
    # echo $nics | jq '.' >> $TEMP_DIR/$transName.nics
    # echo $nbs | jq '.' >> $TEMP_DIR/$transName.nbs

    case $command in
    "prepare")
        if [ $ASYNC -eq 1 ]; then
            ./installRequired.sh $username $password $ip $routerName $mapPort $index &
        else
            ./installRequired.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    "deploy")
        if [ $ASYNC -eq 1 ]; then
            ./deploy.sh $username $password $ip $routerName $mapPort $index &
        else
            ./deploy.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    "update")
        if [ $ASYNC -eq 1 ]; then
         ./update.sh $username $password $ip $routerName $mapPort $index &
        else
            ./update.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    "clone")
        if [ $ASYNC -eq 1 ]; then
            ./clone.sh $username $password $ip $routerName $mapPort $index &
        else
            ./clone.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    "ifconfig")
        if [ $ASYNC -eq 1 ]; then
            ./ifconfig.sh $username $password $ip $routerName $mapPort $index &
        else
            ./ifconfig.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    "start-nfd")
        if [ $ASYNC -eq 1 ]; then
            ./start-nfd.sh $username $password $ip $routerName $mapPort $index &
        else
            ./start-nfd.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    "start-nlsr")
        if [ $ASYNC -eq 1 ]; then
            ./start-nlsr.sh $username $password $ip $routerName $mapPort $index &
        else
            ./start-nlsr.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    "stop")
        if [ $ASYNC -eq 1 ]; then
            ./stop.sh $username $password $ip $routerName $mapPort $index &
        else
            ./stop.sh $username $password $ip $routerName $mapPort $index
        fi
        ;;
    esac

    echo "===========================${routerName} finish============================"
}



for index in `seq 0 $length`
do
    # 获取到路由的名字
    echo
    deal $index
    echo
done
