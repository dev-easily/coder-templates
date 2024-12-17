#!/bin/bash
echo "start to install code server"
uname -a
CODE_SERVER_DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | jq -r '.assets[].browser_download_url' | grep "amd64.deb")
echo "downloading https://www.ghproxy.cn/$CODE_SERVER_DOWNLOAD_URL"
s=1
curl -fL https://www.ghproxy.cn/$CODE_SERVER_DOWNLOAD_URL -o /tmp/code_server.deb
while [[ $? -ne 0 ]];do
     if [[ $s -ge 64 ]];then
         echo "bad network"
         break;
     fi
     s=$((2 * $s))
     echo "waiting $s s" 
     sleep $s
     curl -fL https://www.ghproxy.cn/$CODE_SERVER_DOWNLOAD_URL -o /tmp/code_server.deb
done
sudo dpkg -i /tmp/code_server.deb

# lets encrypt ca, used for download coder-agent from workspace, if access url is https and cert is lets encrypt
sudo mkdir -p /usr/local/share/ca-certificates/extra/
sudo cp /tmp/letsEncrypt.crt /usr/local/share/ca-certificates/extra/
sudo update-ca-certificates
