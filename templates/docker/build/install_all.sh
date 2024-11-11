#!/bin/bash
set -x
cd /tmp
wget https://mirror.ghproxy.com/https://github.com/gohugoio/hugo/releases/download/v0.138.0/hugo_extended_0.138.0_linux-amd64.tar.gz
wget https://mirror.ghproxy.com/https://github.com/sass/dart-sass/releases/download/1.80.6/dart-sass-1.80.6-linux-x64.tar.gz
tar -zxvf hugo_extended_0.138.0_linux-amd64.tar.gz
sudo cp hugo /usr/bin/

tar -zxvf dart-sass-1.80.6-linux-x64.tar.gz
sudo cp dart-sass/sass /usr/bin

sudo chmod +x /usr/bin/hugo
sudo chmod +x /usr/bin/sass
rm -rf /tmp/*
exit 0
