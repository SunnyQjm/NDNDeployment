#!/bin/bash
#command=$(cat testCommand.sh)
echo $command
username=$1
password=$2
ip=$3
name=$4
mapPort=$5

HOME=/home/$username/Documents/NDNDeployment

/usr/bin/expect << EOD
set timeout -1

spawn ssh root@$ip -p$mapPort "
cd $HOME
killall nlsr
$HOME/nlsr_configs/generate.sh $name $HOME
mv nlsr.conf /usr/local/etc/ndn/nlsr.conf
nlsr -f /usr/local/etc/ndn/nlsr.conf 
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
