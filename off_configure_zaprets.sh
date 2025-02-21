#!/bin/sh

URL_REPO="https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs"
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

echo "Remove cron task auto run script configure zaprets.."

grep -v "0 4 \* \* \* wget -O - $URL_REPO/refs/heads/main/configure_zaprets.sh | sh" /etc/crontabs/root > /etc/crontabs/temp
cp -f "/etc/crontabs/temp" "/etc/crontabs/root"
rm -f "/etc/crontabs/temp"

echo "Off configure complete..."
