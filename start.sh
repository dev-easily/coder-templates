#!/bin/bash
export CODER_VERSION="v2.14.2" # 请修改
export POSTGRES_USER="eucoder" # 请修改
export POSTGRES_PASSWORD="eucoderp" # 请修改
export POSTGRES_DB="eucoder" # 请修改
# 设置为创建出来的节点可以访问的地址，最好是 http，会用来在workspace下载 code-agent
# 配置自签名证书或者使用nginx代理，可能会无法下载 code-agent
# https://github.com/coder/coder/blob/main/provisionersdk/scripts/bootstrap_linux.sh
# 或者安装到系统中
# https://github.com/sempie/coder-templates/tree/main/ca-install
export CODER_ACCESS_URL="http://192.168.0.96:7080" 
docker compose -f ./docker-compose.yaml stop
docker compose -f ./docker-compose.yaml up -d
