#!/bin/bash
export USER=$YOUR_USER
docker build --build-arg USER="$USER" -t coder_basic_binary -f Dockerfile_basic .
