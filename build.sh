#!/bin/bash
current_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker compose -f "${current_dir}"/docker-compose.yaml build

target_dir=${current_dir}/build
if [[ -n ${BUILD_DIR} ]];then
    target_dir=${BUILD_DIR}
fi

docker save easy-dev/offline-coder:latest > "${target_dir}"/offline-coder.tar
