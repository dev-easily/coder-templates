# docker build --build-arg USER=youruser .
FROM ubuntu:22.04

ENV GO_VERSION=1.22.3

ENV RUSTUP_DIST_SERVER=https://rsproxy.cn
ENV RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup

ENV NODE_VERSION=20.13.1
ENV NVM_NODEJS_ORG_MIRROR=https://mirrors.ustc.edu.cn/node/
ENV ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
ENV ELECTRON_CUSTOM_DIR=30.0.6
ENV ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/

ARG USER=coder
# you know why
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install curl git sudo vim wget locales libfreetype6 fontconfig build-essential ca-certificates jq -y && \
    fc-cache --force && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    useradd -m -d /home/$USER --groups sudo --shell /bin/bash ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER}

USER ${USER}

# python
RUN sudo apt install python3 python3-pip -y && pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip config set global.index https://mirrors.aliyun.com/pypi && \
    pip config set global.trusted-host mirrors.aliyun.com && \
    pip install setuptools

# golang
RUN cd "/tmp" && \
    wget https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo rm -rf /usr/local/go && sudo tar -C /opt -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo ln -s "/opt/go/bin/"* "/usr/bin/" && \
    go version && \
    go env -w GO111MODULE=on && \
    go env -w GOPROXY=https://goproxy.io,direct && \
    rm -r "/tmp/"*

# nodejs
RUN cd "/tmp" && \
    wget https://registry.npmmirror.com/-/binary/node/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz && \
    sudo tar xvf node-v${NODE_VERSION}-linux-x64.tar.xz -C /opt/ && \
    sudo ln -s "/opt/node-v20.13.1-linux-x64/bin/"* "/usr/bin/" && \
    node --version && \
    npm config set registry https://registry.npmmirror.com && \
    #wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash - && \
    #pnpm setup && \
    npm install --global node-gyp && \
    rm -r "/tmp/"*
  
# rust
ADD config.toml /home/$USER/.cargo/config.toml
RUN sudo chown $USER: /home/$USER/ -R && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    echo ". ~/.cargo/env" >> /home/$USER/.bash_profile && \
    . /home/$USER/.cargo/env && \
    cat /home/$USER/.cargo/config.toml && \
    cargo install crm

# openjdk 17
ADD ./settings.xml /home/$USER/.m2/settings.xml
RUN	cd "/tmp" && \
    wget "https://mirrors.tuna.tsinghua.edu.cn/Adoptium/17/jdk/x64/linux/OpenJDK17U-jdk_x64_linux_hotspot_17.0.12_7.tar.gz" && \
    tar -xzf "OpenJDK17U-jdk_x64_linux_hotspot_17.0.12_7.tar.gz" && \
    ls /tmp/ && \
    sudo mv "/tmp/jdk-17.0.12+7" "/opt/" && \
    sudo ln -s "/opt/jdk-17.0.12+7/bin/"* "/usr/bin/" && \
    sudo chown $USER: /home/$USER/.m2 && \
    rm "/tmp/"* && \
    echo 'public class Main { public static void main(String[] args) { System.out.println("Java code is 正常运行中!"); } }' > Main.java && \
    javac -encoding ISO-8859-1 Main.java && \
    java Main && \
    rm -r "/tmp/"*

# coder-server
ADD ./install.sh letsEncrypt.crt /tmp/
RUN sudo chown $USER: /tmp/* && \
    bash /tmp/install.sh

WORKDIR /home/$USER
