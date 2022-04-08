#!/bin/bash

#安装docker和docker-compose略
SH_PWD=`pwd`
DIR=/root
i=1

# 创建 aptos-node 目录并进入该目录，之后的操作都会在该目录下进行
mkdir -p ${DIR}/aptos$i && cd ${DIR}/aptos$i
# 下载 docker-compose 编排文件
#wget -O ./docker-compose.yaml https://raw.githubusercontent.com/chiugui/aptos/main/docker-compose.yaml
\cp ${SH_PWD}/docker-compose.yaml ./docker-compose.yaml
sed -i s#8080:8080#10${i}0:8080#g ./docker-compose.yaml
sed -i s#9101:9101#11${i}0:9101#g ./docker-compose.yaml
sed -i s#6180:6180#12${i}0:6180#g ./docker-compose.yaml

# 下载 全节点配置文件
#wget -O ./public_full_node.yaml https://raw.githubusercontent.com/chiugui/aptos/main/public_full_node.yaml
\cp ${SH_PWD}/public_full_node.yaml ./public_full_node.yaml
# 下载 创世节点文件
wget -O ./genesis.blob https://devnet.aptoslabs.com/genesis.blob
# 下载 waypoint（可验证检查点）文件
wget -O ./waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
# 拷贝升级脚本
\cp ${SH_PWD}/update_aptos.sh ./update_aptos.sh
# 更新镜像
docker pull aptoslab/tools:devnet
# 生成私钥和公钥
docker run --rm aptoslab/tools:devnet sh -c "echo '开始生成私钥...' && aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file /root/private-key.txt && echo '\n\n开始生成公钥和 Peer ID...' && aptos-operational-tool extract-peer-from-file --encoding hex --key-file /root/private-key.txt --output-file /root/peer-info.yaml && echo '\n\n您的私钥：' && cat /root/private-key.txt && echo '\n\n您的公钥和 Peer ID 信息如下：' && cat /root/peer-info.yaml" >./key.txt 2>&1
Private_key=`sed -n '/您的私钥/{n;p;}' ./key.txt`
Public_key=`sed -n '/---/{n;p;}' ./key.txt |awk -F ':' '{print $1}'`

# 修改配置文件
sed -i "18 a \      identity:\n        type: \"from_config\"\n        key: \"${Private_key}\"\n        peer_id: \"${Public_key}\"" ./public_full_node.yaml

# 启动docker
docker-compose up -d
sleep 120
#查看节点信息
echo "curl 127.0.0.1:11${i}0/metrics 2> /dev/null | grep -m 1 peer_id"
echo "curl 127.0.0.1:11${i}0/metrics 2> /dev/null | grep aptos_state_sync_version | grep type"
