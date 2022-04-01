# optos
optos
https://aptoslabs.com/
https://aptos.dev/
https://wiki.aptos.movemove.org/



# 安装 Docker
wget -O get-docker.sh https://get.docker.com 
sudo sh get-docker.sh
rm -f get-docker.sh

# 安装 docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


## 更新节点
# 进入之前创建的 aptos-node 目录，之后的操作都会在该目录下进行
cd ~/aptos-node
# 关闭节点
docker-compose down

# 查看数据卷
docker volume ls

# 删除数据卷（以上一条命令查询到的 Volume Name 结果为准）
docker volume rm aptos_node_db

# 下载 创世节点文件
wget -O ./genesis.blob https://devnet.aptoslabs.com/genesis.blob
# 下载 waypoint（可验证检查点）文件
wget -O ./waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
