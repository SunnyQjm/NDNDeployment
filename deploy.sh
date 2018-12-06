#!/bin/bash
#command=$(cat testCommand.sh)
echo $command
username=$1
password=$2
ip=$3
routerName=$4
mapPort=$5
index=$6

#./doDeploy.sh $username $password $ip $routerName $mapPort $index
#exit
/usr/bin/expect << EOD
set timeout -1

spawn ssh $username@$ip -p$mapPort "
cd Documents/NDNDeployment
./doDeploy.sh $username $password $ip $routerName $mapPort $index
"
expect {
    "(yes/no)?" {
        send "yes\r";
        expect "password:";
        send "${password}\r";
        exp_continue;
    }
    "password:" {
        send "${password}\r";
        exp_continue;
    }
}
EOD
