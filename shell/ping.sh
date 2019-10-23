#!/bin/bash
# Author: ZHH
# Create Date: 2019-04-22 15:40:51
# Last Modified: 2019-10-23 22:20:00
# Version: V2.4
# Description: Multithread Ping
##################################################################
###新增内容：
###   1、格式化ip文件，将以 , 相隔的ip重新格式化为单行一个IP地址
###   2、进行部分优化
###   3、支持了对整个网段进行连通性的检查
###
##################################################################

par=$1
file=$2


function catalog(){
    if [ ! -d log_ping ];then
        mkdir log_ping
    fi
}


function date_log(){
    time=`date +%Y/%m/%d-%T`
    echo "==============================================" >>log_ping/success-ip.log
    echo $time >>log_ping/success-ip.log
    echo "==============================================" >>log_ping/success-ip.log
    echo "==============================================" >>log_ping/failed-ip.log
    echo $time >>log_ping/failed-ip.log
    echo "==============================================" >>log_ping/failed-ip.log
}

function ip_list(){
    start=`date +%s`
    for i in `cat $file`
    do
    {
            ping -c 2 $i >/dev/null
            if [ "$?" -eq "0" ];then
                echo -e "\033[32m 主机 $i 存活!\033[0m"  && echo $i >>log_ping/success-ip.log
            else
                echo -e "\033[31m 主机 $i 不存活!\033[0m" && echo $i >>log_ping/failed-ip.log
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
                echo -e "\033[32m 主机 $i 存活!\033[0m"  && echo $i >>log_ping/success-ip.log
            else
                echo -e "\033[31m 主机 $i 不存活!\033[0m" && echo $i >>log_ping/failed-ip.log
            fi
    }&
    done
    wait
    stop=`date +%s`
    DATE=`expr $stop - $start`
    echo -e "总共花费时间 $DATE"
}

function segment(){
    start=`date +%s`
    for i in `seq 254`
    do
    {
        ping -c 2 $file.$i >/dev/null
        if [ "$?" -eq "0" ];then
            echo -e "\033[32m 主机 $file.$i 存活!\033[0m"  && echo $file.$i >>log_ping/success-ip.log
        else
            echo -e "\033[31m 主机 $file.$i 不存活!\033[0m" && echo $file.$i >>log_ping/failed-ip.log
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
    echo -e "\t\033[33m -s 整个网段,示例：192.168.1 (只填写网络位地址即可)\033[0m"
    echo -e "\t\033[33m -f 每行单个IP的文件名（支持绝对路径和相对路径）\033[0m"
    echo -e "\t\033[33m -t 存放以逗号相隔IP的文件名（支持绝对路径和相对路径）\033[0m"
}

case $par in
    -o)
        if [ "$file" == "" ];then
        	Help
        else
	        ping -c 2 $file >>/dev/null
	        if [ "$?" -eq "0" ];then
	            echo -e "\033[32m 主机 $file 存活!\033[0m"
	        else
	            echo -e "\033[31m 主机 $file 不存活!\033[0m"
	        fi
	    fi
    ;;
    -s)
        catalog
        date_log
        segment
	    #echo -e "\033[31m 正在开发中，敬请期待！\033[0m"
    ;;
    -f)
        catalog
        date_log
        ip_list
    ;;
    -t)
        catalog
        date_log
        TR=`cat $file | tr "," "\n"`
        tr_iplist
    ;;
    *)
        Help
    ;;
esac
