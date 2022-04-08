#!/bin/bash

DIR=`pwd |awk -F '/' '{print $NF}'`

#1.关闭节点
docker-compose down

#2.删除docker volume
docker volume rm ${DIR}_db

#3.删除文件重新下载
# 下载 创世节点文件
wget -O ./genesis.blob https://devnet.aptoslabs.com/genesis.blob
# 下载 waypoint（可验证检查点）文件
wget -O ./waypoint.txt https://devnet.aptoslabs.com/waypoint.txt

#4.更新节点镜像
docker-compose pull

#5.启动全节点
docker-compose up -d

