本仓库提供了一个离线安装 coder 的示例，两个可以使用的 coder 模板：

1. 在 proxmox 上快速搭建 vm
2. 在 一台安装有 docker 的 linux 机器使用 docker 快速创建开发环境

非常适合中国大陆的个人开发者初步把玩一下 coder。

本文档不是一个严谨的、一步一步指导你完成所有概念学习和使用的文档，你必须自己完成大部分的学习和探索任务，本仓库只是提供了在中国大陆完成 coder 调测的方法。

## 一些基础知识
coder 支持在各种云服务器上快速创建开发环境，并且你可以一键使用在线版的 vscode（code server）连接到这个开发环境。

不过使用云服务器开发？对于普通的个人开发者来说基本用不上。

然而 coder/terraform 还支持自定义的 provider（provider可以理解为服务商，阿里云或者亚马逊，给你提供机器），而 pve 和你一台安装了 docker 的 linux 机器就摇身一变，变成了 provider。

通过 telmate/proxmox provider，你可以在 pve 上基于 iso 或已有的 vm 并配合 cloud-init 快速搭建一台开发环境。

通过 kreuzwerker/docker provider，你可以在一台安装了 docker 的 linux 机器上，创建任意的镜像。

本仓库就提供了两个快速在 pve 和 docker 上快速部署开发环境的 coder 模板。

## 安装离线版的 coder
因为中国网络的原因，个人开发者应该首选离线版 coder。

coder 官网给出了离线版 coder 的安装步骤，但是仍然建议你用本仓库的 Dockerfile，因为离线版的 coder 仍然有一些你无法下载下来的东西，比如 hashicorp/null hashicorp/local 等。

因此我将这些包下载后，上传到了 regfistry.terraform.io 文件夹中。
### 前提条件
一个用于安装离线 docker 版本 coder 的 linux 虚拟机，你需要在此虚拟机上事先安装好 docker 和 docker compose，并设置好中国可用的镜像（2024年后国内docker使用更难了，关于如何设置后面我再写一篇文章）

### 安装步骤
1. 在要安装 coder 的机器上下载本仓库，执行
   ```bash
   docker compose -f ./docker-compose.yaml build
   export CODER_VERSION="v2.14.2"
   export POSTGRES_USER="eucoder" # 请修改
   export POSTGRES_PASSWORD="eucoderp" # 请修改
   export POSTGRES_DB="eucoder" # 请修改
   export CODER_ACCESS_URL="http://192.168.0.96:7080" # 请修改为 coder 用户可以访问的地址，自己调测可以先写成安装的 coder 访问地址和端口
   docker compose -f ./docker-compose.yaml up -d
   ```
2. 启动后，设置用户名、邮箱（一些模板会将用户名和邮箱直接作为 git 的 user.name 和 user.email，建议不要随意设置）和密码


## 创建 pve vm 类型的开发环境 

### 前提条件
1. 安装好的 pve
2. pve 登录账号（最好选用 pam），密码，该账号的 token id 和 token secret
3. 一个事先安装好的 vm 以及它的名称，如 ubuntu2204
4. 离线版的 coder

### 步骤

1. 登录 coder，点击 Templates，创建一个模板
2. 可以选择 scratch 从 0 创建，然后将本仓库的 templates 下的 pve 中的文件粘贴进去
3. 也可以将本仓库的 templates 下的 pve 中的文件，压缩上传
   ```text
   pve.zip
      | -- main.tf
      | -- cloud-config.yaml.tfpl
   ```
### 更改 pve 相关的参数
请花点时间看看 main.tf 的构成，在 pve 中的 main.tf 中搜索 "请修改" 字样，将这些字样修改为你的用户名，密码，机器地址等。

点击 build 通过后，就可以创建 workspace 了。

## 创建 docker 类型的开发环境
该部分内容因为不需要 pve，对于只想了解 coder 是什么的人更为适合。

### 前提条件
1. 离线版的 coder

### 步骤
1. 点击 Templates，创建一个模板
2. 可以选择 scratch 从 0 创建，然后将本仓库的 templates 下的 docker 中的文件粘贴进去
3. 也可以将本仓库的 templates 下的 docker 中的文件，压缩上传
   ```text
   docker.zip
      | -- main.tf
      | -- build
          | -- *
   ```
4. 默认的 Dockerfile 带了 python，node，java，go，rust 等 sdk，你可以删除你不需要的，或者将这些分散的命令放入一个 RUN 命令中以减小镜像大小

点击 build 通过后，就可以创建 workspace 了。