#!/bin/bash
username=$1
password=$2
ip=$3
routerName=$4
mapPort=$5
idx=$6

echo 1: $1
echo 2: $2
echo 3: $3
echo 4: $4
echo 5: $5
echo 6: $6

echo username: $username
echo inputName: $routerName

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
    rName=$(echo $list | jq -r ".[$index].name")
    nbs=$(echo $list | jq  ".[$index].nbs")
    nics=$(echo $list | jq ".[$index].nics")

    transName=$(echo ${rName//\//.})
    transName=$(echo ${transName#.})
    echo $nics | jq '.' > $TEMP_DIR/$transName.nics
    echo $nbs | jq '.' > $TEMP_DIR/$transName.nbs
done


transName=$(echo ${routerName//\//.})
transName=$(echo ${transName#.})

echo transName: $transName
# 当前节点的邻居信息
myNbs=$(cat $TEMP_DIR/$transName.nbs)
myNics=$(cat $TEMP_DIR/$transName.nics)

echo myNbs:
echo $myNbs | jq '.'
echo myNics:
echo $myNics | jq '.'
myNbsNum=`echo $nbs | jq '.|length'`
let 'myNbsNum=myNbsNum-1'

echo ~~begin deal neighbout~~
for i in `seq 0 $myNbsNum`
do
    # 得到邻居的名字
    neighbourName=$(echo $myNbs | jq -r ".[$i].name")
    myIndex=$(echo $myNbs | jq -r ".[$i].nicIndex")
    
    localUri=dev://$(echo $myNics | jq -r ".[$myIndex].name")


    # 得到该邻居的网卡信息
    transName=$(echo ${neighbourName//\//.})
    transName=$(echo ${transName#.})
    neighbourNics=$(cat $TEMP_DIR/$transName.nics)
    neighbourNbs=$(cat $TEMP_DIR/$transName.nbs)
    neighbourNbsNum=`echo $neighbourNbs | jq '.|length'`
    #echo $neighbourNbs
    #echo neighbourNbsNum: $neighbourNbsNum
    let 'neighbourNbsNum=neighbourNbsNum-1'
    #echo neighbourNbsNum: $neighbourNbsNum
    for j in `seq 0 $neighbourNbsNum`
    do
        judgeName=$(echo $neighbourNbs | jq -r ".[$j].name")
        echo $judgeName
        if [ "$judgeName"x == "$routerName"x ]; then
            tempIdx=$(echo $neighbourNbs | jq -r ".[$j].nicIndex")
            #echo tempIdx: $tempIdx
            #echo $neighbourNics | jq -r ".[$tempIdx].mac"
            remoteUri=ether://[$(echo $neighbourNics | jq -r ".[$tempIdx].mac")]
        fi
    done

    # 为该邻居创建Face
    echo "正在为邻居$neighbourName创建Face"
    echo "nfdc face create remote $remoteUri local $localUri" 
    nfdc face create remote $remoteUri local $localUri 
    
done

