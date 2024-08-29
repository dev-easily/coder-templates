#!/bin/bash
export CODER_VERSION="v2.14.2" # 请修改
export POSTGRES_USER="eucoder" # 请修改
export POSTGRES_PASSWORD="eucoderp" # 请修改
export POSTGRES_DB="eucoder" # 请修改
export CODER_ACCESS_URL="http://192.168.0.96:7080" # 请修改
docker compose -f ./docker-compose.yaml stop
docker compose -f ./docker-compose.yaml up -d