#!/bin/bash

#安装docker和docker-compose略
#docker network create --driver bridge --subnet 10.0.0.0/16 --gateway 10.0.0.1  aptos_network
DIR=/aptos
SH_PWD=`pwd`
IP=`hostname -I |awk '{print $1}'`

for i in {1..1}
do

# 创建 aptos-node 目录并进入该目录，之后的操作都会在该目录下进行
#rm -f ${SH_PWD}/perr_id.list
mkdir -p ${DIR}/aptos$i/data  && cd ${DIR}/aptos$i && echo "创建目录:${DIR}/aptos$i 成功！"

# 下载 docker-compose 编排文件
#wget -O ./docker-compose.yaml https://raw.githubusercontent.com/chiugui/aptos/main/docker-compose.yaml
\cp ${SH_PWD}/docker-compose.yaml ./docker-compose.yaml && echo "拷贝docker-compose.yaml 成功！"
sed -i s#8080:8080#10${i}0:8080#g ./docker-compose.yaml
sed -i s#9101:9101#11${i}0:9101#g ./docker-compose.yaml
sed -i s#6180:6180#12${i}0:6180#g ./docker-compose.yaml

# 下载 全节点配置文件
#wget -O ./public_full_node.yaml https://raw.githubusercontent.com/chiugui/aptos/main/public_full_node.yaml
\cp ${SH_PWD}/public_full_node.yaml ./public_full_node.yaml && echo "拷贝public_full_node.yaml 成功！"

# 下载 创世节点文件
wget -O ./genesis.blob https://devnet.aptoslabs.com/genesis.blob
# 下载 waypoint（可验证检查点）文件
wget -O ./waypoint.txt https://devnet.aptoslabs.com/waypoint.txt

# 拷贝升级脚本
\cp ${SH_PWD}/update_aptos.sh ./update_aptos.sh

# 更新镜像
docker pull aptoslab/tools:devnet

# 生成私钥和公钥
docker run --rm aptoslab/tools:devnet sh -c "echo '开始生成私钥...' && aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file /root/private-key.txt && echo '\n\n开始生成公钥和 Peer ID...' && aptos-operational-tool extract-peer-from-file --encoding hex --key-file /root/private-key.txt --output-file /root/peer-info.yaml && echo '\n\n您的私钥：' && cat /root/private-key.txt && echo '\n\n您的公钥和 Peer ID 信息如下：' && cat /root/peer-info.yaml" >./key.txt 2>&1 && echo "生成密钥成功！"
Private_key=`sed -n '/您的私钥/{n;p;}' ./key.txt`
#Public_key和peer_id相同
Public_key=`sed -n '/---/{n;p;}' ./key.txt |awk -F ':' '{print $1}'`

# 修改密钥文件权限
chmod 0400 ./key.txt

# 修改配置文件
#sed -i "22 a \      identity:\n        type: \"from_config\"\n        key: \"${Private_key}\"\n        peer_id: \"${Public_key}\"" ./public_full_node.yaml && echo "修改配置文件成功！"
sed -i '/      discovery_method: "onchain"$/a\
      identity:\
          type: "from_config"\
          key: "'${Private_key}'"\
          peer_id: "'${Public_key}'"' public_full_node.yaml
chmod 0600 ./public_full_node.yaml

# 启动docker
docker-compose up -d
echo "节点启动中，请稍后......"
sleep 20
echo "peer_id_${i}:${Public_key}" && echo "peer_${i}:${Public_key}:${Private_key}" >> ${SH_PWD}/peer_id_${IP}.list 2>&1
chmod 0600 ${SH_PWD}/peer_id_${IP}.list

#查看节点信息
curl -s 127.0.0.1:11${i}0/metrics | grep aptos_state_sync_version | grep type
echo "查看节点信息,请使用如下命令:"
echo "curl 127.0.0.1:11${i}0/metrics 2> /dev/null | grep -m 1 peer_id"
echo "curl 127.0.0.1:11${i}0/metrics 2> /dev/null | grep aptos_state_sync_version | grep type"

done
