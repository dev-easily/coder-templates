#!/bin/bash
echo "start to install code server"
uname -a
CODE_SERVER_DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | jq -r '.assets[].browser_download_url' | grep "amd64.deb")
echo "downloading https://mirror.ghproxy.com/$CODE_SERVER_DOWNLOAD_URL"
s=1
curl -fL https://mirror.ghproxy.com/$CODE_SERVER_DOWNLOAD_URL -o /tmp/code_server.deb
while [[ $? -ne 0 ]];do
     if [[ $s -ge 64 ]];then
         echo "bad network"
         break;
     fi
     s=$((2 * $s))
     echo "waiting $s s" 
     sleep $s
     curl -fL https://mirror.ghproxy.com/$CODE_SERVER_DOWNLOAD_URL -o /tmp/code_server.deb
done
sudo dpkg -i /tmp/code_server.deb