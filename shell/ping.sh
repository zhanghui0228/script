#!/bin/bash
# Author: ZHH
# Create Date: 2019-04-22 15:40:51
# Last Modified: 2019-08-21 15:55:51
# Version: V2.1
# Description: Multithread Ping
##################################################################
###新增内容：
###   1、格式化ip文件，将以 , 相隔的ip重新格式化为单行一个IP地址
###   2、进行部分优化
###
##################################################################

par=$1
file=$2

if [ ! -d log$(date +%Y%m%d) ];then
	mkdir log$(date +%Y%m%d)
fi

function clean_log(){
    echo >log$(date +%Y%m%d)/success-ip.log
    echo >log$(date +%Y%m%d)/failed-ip.log
}

function ip_list(){
    start=`date +%s`
    for i in `cat $file`
    do
    {
            ping -c 2 $i >/dev/null
            if [ "$?" -eq "0" ];then
                echo -e "\033[32m 主机 $i 存活!\033[0m"  && echo $i >>log$(date +%Y%m%d)/success-ip.log
            else
                echo -e "\033[31m 主机 $i 不存活!\033[0m" && echo $i >>log$(date +%Y%m%d)/failed-ip.log
            fi
    }&
    done
    wait
    stop=`date +%s`
    DATE=`expr $stop - $start`
    echo -e "总共花费时间 $DATE"
}

function tr_iplist(){
    start=`date +%s`
    for i in `echo $TR`
    do
    {
            ping -c 2 $i >/dev/null
            if [ "$?" -eq "0" ];then
                echo -e "\033[32m 主机 $i 存活!\033[0m"  && echo $i >>log$(date +%Y%m%d)/success-ip.log
            else
                echo -e "\033[31m 主机 $i 不存活!\033[0m" && echo $i >>log$(date +%Y%m%d)/failed-ip.log
            fi
    }&
    done
    wait
    stop=`date +%s`
    DATE=`expr $stop - $start`
    echo -e "总共花费时间 $DATE"
}

function Help(){
	echo -e "\033[33m 请输入参数{-o|-f|-t}\033[0m "
    echo -e "\t\033[33m -o 单个IP地址\033[0m"
    echo -e "\t\033[33m -s 整个网段,示例：192.168.1.0/24\033[0m"
    echo -e "\t\033[33m -f 每行单个IP的文件名（支持绝对路径和相对路径）\033[0m"
    echo -e "\t\033[33m -t 存放以逗号相隔IP的文件名（支持绝对路径和相对路径）\033[0m"
}

case $par in
    -o)
        if [ "$file" == "" ];then
        	Help
        else
	        echo >log$(date +%Y%m%d)/failed-ip.log
	        ping -c 2 $file >>/dev/null
	        if [ "$?" -eq "0" ];then
	            echo -e "\033[32m 主机 $file 存活!\033[0m"
	        else
	            echo -e "\033[31m 主机 $file 不存活!\033[0m"
	        fi
	    fi
    ;;
    -s)
	echo -e "\033[31m 正在开发中，敬请期待！\033[0m"
    ;;
    -f)
        clean_log
        ip_list
    ;;
    -t)
        clean_log
        TR=`cat $file | tr "," "\n"`
        tr_iplist
    ;;
    *)
        Help
    ;;
esac

