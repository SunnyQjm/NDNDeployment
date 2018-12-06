#!/bin/bash
#command=$(cat testCommand.sh)
echo $command
username=$1
password=$2
ip=$3
name=$4
mapPort=$5
/usr/bin/expect << EOD
set timeout -1

spawn ssh root@$ip -p$mapPort "
cd /home/$username/Documents/NDNDeployment
killall nlsr
./nlsr_configs/generate.sh
nlsr -f ./nlsr_configs/nlsr.conf 
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
