#!/bin/sh

DIR="/etc/config"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"

echo "Restore configs..."

for file in $config_files
do
  cp -f "$DIR_BACKUP/$file" "$DIR/$file"   
done

echo "Restart service..."

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart
service odhcpd restart

echo "Off configure complete..."
