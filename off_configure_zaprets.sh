#!/bin/sh

URL="https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main"
DIR="/etc/config"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"

if [ -d "$DIR_BACKUP" ]
then
  echo "Restore configs..."
  for file in $config_files
  do
    cp -f "$DIR_BACKUP/$file" "$DIR/$file"   
  done

  rm -rf "$DIR_BACKUP"
fi

echo "Restart service..."

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart
service odhcpd restart

echo "Remove cron task auto run script configure zaprets.."

str=$(grep -i "0 4 \* \* \* wget -O - $URL/configure_zaprets.sh | sh" /etc/crontabs/root)
if [ ! -z "$str" ]
then
	grep -v "0 4 \* \* \* wget -O - $URL/configure_zaprets.sh | sh" /etc/crontabs/root > /etc/crontabs/temp
	cp -f "/etc/crontabs/temp" "/etc/crontabs/root"
	rm -f "/etc/crontabs/temp"
fi

printf  "\033[32;1mOff configured completed...\033[0m\n"
