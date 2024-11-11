#!/bin/bash
export USER=$YOUR_USER
docker build --build-arg USER="$USER" .
