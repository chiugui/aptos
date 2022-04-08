#!/bin/bash

#安装docker和docker-compose略

i=1
# 创建 aptos-node 目录并进入该目录，之后的操作都会在该目录下进行
mkdir -p ~/aptos-node-$i && cd ~/aptos-node-$i
# 下载 docker-compose 编排文件
wget -O ./docker-compose.yaml https://raw.githubusercontent.com/chiugui/aptos/main/docker-compose.yaml
# 下载 全节点配置文件
wget -O ./public_full_node.yaml https://raw.githubusercontent.com/chiugui/aptos/main/public_full_node.yaml
# 下载 创世节点文件
wget -O ./genesis.blob https://devnet.aptoslabs.com/genesis.blob
# 下载 waypoint（可验证检查点）文件
wget -O ./waypoint.txt https://devnet.aptoslabs.com/waypoint.txt

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

#查看节点信息
curl 127.0.0.1:9101/metrics 2> /dev/null | grep -m 1 peer_id
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
