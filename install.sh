#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
# [[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

install_base() {
	apt-get update && apt-get install -y -q wget curl tar tzdata  
}

config_after_install() {
    local username="$1"
	local password="$2"
	local port="$3"
	local webBasePath="$4"
	/usr/local/x-ui/x-ui setting -username "${username}" -password "${password}" -port "${port}" -webBasePath "${webBasePath}"
    /usr/local/x-ui/x-ui migrate
}

install_x-ui() {
    cd /usr/local/
	last_version="v2.4.2"
	url="https://github.com/MHSanaei/3x-ui/releases/download/${last_version}/x-ui-linux-amd64.tar.gz"
	wget -N --no-check-certificate -O /usr/local/x-ui-linux-amd64.tar.gz ${url}
	if [[ $? -ne 0 ]]; then
		# echo -e "${red}Download x-ui $1 failed,please check the version exists ${plain}"
		exit 1
	fi
    

    if [[ -e /usr/local/x-ui/ ]]; then
        systemctl stop x-ui
        rm /usr/local/x-ui/ -rf
    fi

    tar zxvf x-ui-linux-amd64.tar.gz
    rm x-ui-linux-amd64.tar.gz -f
    cd x-ui
    chmod +x x-ui

    chmod +x x-ui bin/xray-linux-amd64
    cp -f x-ui.service /etc/systemd/system/
    wget --no-check-certificate -O /usr/bin/x-ui https://raw.githubusercontent.com/dmitrybaev1/3x-ui/refs/heads/main/x-ui.sh
    chmod +x /usr/local/x-ui/x-ui.sh
    chmod +x /usr/bin/x-ui
    config_after_install $1 $2 $3 $4

    systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
}

install_base
install_x-ui 
