#!/bin/sh

URL="https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs/refs/heads/main"
DIR="/root"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"

config_backup="dhcp_backup
youtubeUnblock_backup
https-dns-proxy_backup"


for file in $config_files
do
  cp -f "$DIR_BACKUP/$file" "$DIR/$file" 
done

for file in $config_files
do
  wget -O "$DIR/$file" "$URL/$file" 
done