#!/bin/sh

URL="https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs/refs/heads/main"
DIR="/etc/config"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"


mkdir $DIR_BACKUP

for file in $config_files
do
  cp -f "$DIR_BACKUP/$file" "$DIR/$file"   
done

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart