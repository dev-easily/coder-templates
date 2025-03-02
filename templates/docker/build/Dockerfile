# docker build --build-arg USER=youruser .
FROM coder_basic_binary:latest

ENV GO_VERSION=1.24.0

ENV RUSTUP_DIST_SERVER=https://rsproxy.cn
ENV RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup

ENV NODE_VERSION=22.14.0
ENV NVM_NODEJS_ORG_MIRROR=https://mirrors.ustc.edu.cn/node/
ENV ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
ENV ELECTRON_CUSTOM_DIR=30.0.6
ENV ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/

ARG USER=coder
USER ${USER}

# python
RUN sudo apt install -y python3 pipx
#RUN mkdir -p ~/miniconda3 && \
#    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh && \
#    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && \
#    rm ~/miniconda3/miniconda.sh

# golang
RUN cd "/tmp" && \
    wget https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo rm -rf /usr/local/go && sudo tar -C /opt -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo ln -s "/opt/go/bin/"* "/usr/bin/" && \
    go version && \
    go env -w GO111MODULE=on && \
    go env -w GOPROXY=https://goproxy.io,direct && \
    go install golang.org/x/tools/cmd/godoc@latest && \
    echo "export PATH=\$PATH:~/go/bin" >> ~/.bash_profile && \
    rm -r "/tmp/"*

# nodejs
RUN cd "/tmp" && \
    wget https://registry.npmmirror.com/-/binary/node/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz && \
    sudo tar xvf node-v${NODE_VERSION}-linux-x64.tar.xz -C /opt/ && \
    sudo ln -s "/opt/node-v${NODE_VERSION}-linux-x64/bin/"* "/usr/bin/" && \
    node --version && \
    npm config set registry https://registry.npmmirror.com && \
    #wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash - && \
    #pnpm setup && \
    sudo chown $USER: /opt/node* -R && \
    npm install -g pnpm && \
    echo "export PATH=\$PATH:/opt/node-v${NODE_VERSION}-linux-x64/bin/" >> ~/.bash_profile && \
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

# openjdk 21
#ADD ./settings.xml /home/$USER/.m2/settings.xml
#RUN	cd "/tmp" && \
#    wget "https://mirrors.tuna.tsinghua.edu.cn/Adoptium/21/jdk/x64/linux/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz" && \
#    tar -xzf "OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz" && \
#    ls /tmp/ && \
#    sudo mv "/tmp/jdk-21.0.5+11" "/opt/" && \
#    sudo ln -s "/opt/jdk-21.0.5+11/bin/"* "/usr/bin/" && \
#    sudo chown $USER: /home/$USER/.m2 && \
#    rm "/tmp/"* && \
#    echo 'public class Main { public static void main(String[] args) { System.out.println("Java code is 正常运行中!"); } }' > Main.java && \
#    javac -encoding ISO-8859-1 Main.java && \
#    java Main && \
#    rm -r "/tmp/"*

WORKDIR /home/$USER
