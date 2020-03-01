#!/bin/bash
# CHFS File Server for CentOS

#CHFS监听端口
insport="8000"
#CHFS共享根目录(需要加/)
webdir="/var/chfsdir/"
#CHFS安装目录(需要加/)
insdir="/opt/"

chfsdir="${insdir}chfs/"
case $1 in
    #Install chfs
    install)
        #检查是否已安装
        if [ -a ${chfsdir}chfs ] && [ -a ${chfsdir}config.ini ] && [ -a ${chfsdir}cfs.sh ]; then echo -e "\033[0;31;1m### CHFS is installed, please uninstall the previous program before installing again!\033[0m" && echo "" && exit 1; else echo -e "\033[0;32;1m### Start install CHFS...\033[0m";fi
        #文件完整性校验
        if [ -a chfs ] && [ -a config.ini ] && [ -a chfs.service ] && [ -a cfs.sh ] && [ -d ssl ]; then echo -e "\033[0;32;1m### File Check Success!\033[0m"; else echo -e "\033[0;31;1m### One or more files were not found!\033[0m" && echo "" && exit 1;fi
        #判断是否ROOT用户并安装screen
        if [[ `whoami` == "root" ]]; then if [[ -n "$(cat /etc/redhat-release|grep -i centos)" ]]; then if rpm -qa|grep screen>/dev/null; then chmod +x ./chfs && chmod +x ./*.sh;else yum install -y screen || echo -e "\033[0;31;1m### Screen install error!\033[0m" || exit 1; fi else echo -e "\033[0;31;1m### Operating system is not supported.\033[0m" && echo "" && exit 1;fi else echo -e "\033[0;31;1m### Please run as root user!\033[0m" && echo "" && exit 1;fi
        #写入配置文件
        if cat ./config.ini|grep path>/dev/null; then sed -i '/path=/d' ./config.ini && echo "path=\"${webdir}\"">>./config.ini;else echo "path=\"${webdir}\"">>./config.ini; fi
        if cat ./config.ini|grep port>/dev/null; then sed -i '/port=/d' ./config.ini && echo "port=${insport}">>./config.ini;else echo "port=${insport}">>./config.ini; fi
        #检查共享根目录是否存在,复制安装文件到安装目录,建立软链接
        if [[ -d ${webdir} ]]; then mkdir -p ${chfsdir} && cp -R ./* ${chfsdir} && chmod +x /etc/rc.local && ln -s ${chfsdir}cfs.sh /usr/bin/cfs.sh && echo -e "\033[0;32;1m### Install Success!\033[0m";else mkdir -p ${chfsdir} && mkdir -p ${webdir} && cp -R ./* ${chfsdir} && chmod +x /etc/rc.local && ln -s ${chfsdir}cfs.sh /usr/bin/cfs.sh && echo -e "\033[0;32;1m### Install Success!\033[0m";fi
        #判断centos版本安装服务,添加自启,启动服务
        if [[ "$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')/1" > 6 ]]; then cp ./chfs.service /usr/lib/systemd/system/ && systemctl daemon-reload && systemctl start chfs.service && systemctl enable chfs.service && echo -e "\033[0;32;1m### Start Success!\033[0m"; else if cat /etc/rc.local|grep chfs>/dev/null; then sed -i '/screen -dmS chfs/d' /etc/rc.local && echo "screen -dmS chfs ${chfsdir}chfs --file=${chfsdir}config.ini">>/etc/rc.local && screen -dmS chfs ${chfsdir}chfs --file=${chfsdir}config.ini && echo -e "\033[0;32;1m### Start Success!\033[0m"; else echo "screen -dmS chfs ${chfsdir}chfs --file=${chfsdir}config.ini">>/etc/rc.local && screen -dmS chfs ${chfsdir}chfs --file=${chfsdir}config.ini && echo -e "\033[0;32;1m### Start Success!\033[0m"; fi ; fi
        echo -e "\033[0;32;1m------ CHFS Install Info ------\033[0m"
        echo -e "\033[0;32;1m Default Port: ${insport}\033[0m"
        echo -e "\033[0;32;1m Web Path: ${webdir}\033[0m"
        echo -e "\033[0;32;1m Install Path: ${chfsdir}\033[0m"
        echo -e "\033[0;32;1m Config File: ${chfsdir}config.ini\033[0m"
        echo -e "\033[0;32;1m Default Username: admin\033[0m"
        echo -e "\033[0;32;1m Default Password: admin\033[0m"
        echo -e "\033[0;32;1m-------------------------------\033[0m"
        echo -e "\033[0;32;1mUse the <cfs.sh help> command to get help information.\033[0m"
        echo ""
    ;;
    #Uninstall
    uninstall)
        echo -e "\033[0;32;1m### Uninstall CHFS...\033[0m"
        #查找并杀死进程
        if [[ -n "$(ps -A|grep chfs)" ]]; then if [[ "$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')/1" > 6 ]]; then systemctl stop chfs.service && echo -e "\033[0;32;1m    CHFS Stopping...\033[0m";else ps -A | grep "chfs" | awk '{print $1}' | xargs kill -9 && echo -e "\033[0;32;1m    CHFS Stopping...\033[0m";fi; else echo -e "\033[0;32;1m### CHFS Stopped\033[0m"; fi
        rm -rf ${chfsdir} && echo -e "\033[0;32;1m    Deleting install directory...\033[0m"
        rm -rf /usr/bin/cfs.sh && echo -e "\033[0;32;1m    Deleting CHFS link...\033[0m"
        #卸载服务
        if [[ "$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')/1" > 6 ]]; then rm -rf /usr/lib/systemd/system/chfs.service &&  systemctl daemon-reload && echo -e "\033[0;32;1m### Uninstall Success!\033[0m"; else if cat /etc/rc.local|grep chfs>/dev/null; then sed -i '/screen -dmS chfs/d' /etc/rc.local && echo -e "\033[0;32;1m### Uninstall Success!\033[0m";else echo -e "\033[0;32;1m### Uninstall Success!\033[0m"; fi ;fi
        echo ""
    ;;
    #Start chfs
    start)
        if [[ -n "$(ps -A|grep chfs)" ]]; then echo -e "\033[0;32;1m### CHFS Running...\033[0m";else if [[ "$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')/1" > 6 ]]; then systemctl start chfs.service && echo -e "\033[0;32;1m### CHFS Start Success!\033[0m"; else screen -dmS chfs ${chfsdir}chfs --file=${chfsdir}config.ini && echo -e "\033[0;32;1m### CHFS Start Success!\033[0m"; fi ;fi
        echo ""
    ;;
    #Stop chfs
    stop)
	if [[ "$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')/1" > 6 ]]; then systemctl stop chfs.service && echo -e "\033[0;32;1m### Stop CHFS Success!\033[0m";else ps -A | grep "chfs" | awk '{print $1}' | xargs kill -9 && echo -e "\033[0;32;1m### Stop CHFS Success!\033[0m";fi
        echo ""
    ;;
    #Restart chfs
    restart)
        if [[ -n "$(ps -A|grep chfs)" ]]; then ps -A | grep "chfs" | awk '{print $1}' | xargs kill -9 && screen -dmS chfs ${chfsdir}chfs --file=${chfsdir}config.ini && echo -e "\033[0;32;1m### CHFS Restart Success!\033[0m"; else screen -dmS chfs ${chfsdir}chfs --file=${chfsdir}config.ini && echo -e "\033[0;32;1m### CHFS Restart Success!\033[0m"; fi
        echo ""
    ;;
    help)
        echo -e "\033[0;32;1m-------- Usage CHFS Command -------\033[0m"
        echo -e "\033[0;32;1m Start CHFS:    cfs.sh start\033[0m"
        echo -e "\033[0;32;1m Stop  CHFS:    cfs.sh stop\033[0m"
        echo -e "\033[0;32;1m Restart  CHFS: cfs.sh restart\033[0m"
        echo -e "\033[0;32;1m Install  CHFS: cfs.sh install\033[0m"
        echo -e "\033[0;32;1m Unnstall CHFS: cfs.sh uninstall\033[0m"
        echo -e "\033[0;32;1m-----------------------------------\033[0m"
        echo ""
    ;;
    *)
        echo -e "\033[0;32;1m### The input value is invalid, please try again...\033[0m"
        echo -e "\033[0;32;1mUse the <cfs.sh help> command to get help information.\033[0m"
        echo ""
    ;;
esac
