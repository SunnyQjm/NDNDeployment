#!/bin/bash
username=$1
password=$2
ip=$3
routerName=$4
mapPort=$5
idx=$6;

cd ~/Documents/NDNDeployment

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

TEMP_DIR='./temp'
# 创建temp文件夹存放中转数据
ensureDir $TEMP_DIR



# 读取网络拓扑配置
json=`cat lab_topology.json`

# 保存配置列表
list=`echo $json | jq '.'`

# 获取网络拓扑的节点个数
length=`echo $json | jq '.|length'` 
length=$(( $length - 1 ))

# 将节点信息和邻居信息输出到temp文件夹
for index in `seq 0 $length`
do
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

    transName=$(echo ${routerName//\//.})
    transName=$(echo ${transName#.})
    echo $nics | jq '.' >> $TEMP_DIR/$transName.nics
    echo $nbs | jq '.' >> $TEMP_DIR/$transName.nbs
done

# 当前节点的邻居信息
myNbs=$(cat $TEMP_DIR/$routerName.nbs)
myNics=$(cat $TEMP_DIR/$routerName.nics)
myNbsNum=`echo $nbs | jq '.|length'`
let 'myNbsNum = myNbsNum - 1'

for i in `seq 0 $myNbsNum`
do
    # 得到邻居的名字
    neighbourName=$(echo $nbs | jq -r ".[$i].name")
    myIndex=$(echo $nbs | jq -r ".[$i].name")
    
    localUri=dev://$(echo $myNics | jq -r ".[$myIndex].name")


    # 得到该邻居的网卡信息
    neighbourNics=$(cat $TEMP_DIR/$neighbourName.nics)
    neighbourNbs=$(cat $TEMP_DIR/$neighbourName.nbs)
    neighbourNbsNum=`echo $neighbourNbs | jq '.length'`
    let 'neighbourNbsNum = neighbourNbsNum - 1'
    for j in `seq 0 $neighbourNbsNum`
    do
        if [ $(echo neighbourNbs | jq -r ".[$j].name") -eq routerName ]; then
            tempIdx=$(echo neighbourNbs | jq -r ".[$j].nicIndex")
            remoteUri=ether://[$(echo $neighbourNics | jq -r ".[$tempIdx].mac")]
        fi
    done

    # 为该邻居创建Face
    echo "正在为邻居$neighbourName创建Face"
    echo "nfdc face create remote $remoteUri local $localUri" 
    #nfdc face create remote $remoteUri local $localUri 
    
done

