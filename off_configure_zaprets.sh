#!/bin/sh

DIR="/etc/config"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"

for file in $config_files
do
  cp -f "$DIR_BACKUP/$file" "$DIR/$file"   
done

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart