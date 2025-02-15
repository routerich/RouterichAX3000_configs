#!/bin/sh

URL="https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs/refs/heads/main"
DIR="/etc/config"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"

echo "Backup files..."

if [ ! -d "$DIR_BACKUP" ]
then
  mkdir $DIR_BACKUP
fi

for file in $config_files
do
  cp -f "$DIR/$file" "$DIR_BACKUP/$file"  
done

echo "Replace configs..."

for file in $config_files
do
  if [ "$file" != "dhcp" ] 
  then 
    wget -O "$DIR/$file" "$URL/$file" 
  fi
done

echo "Configure dhcp..."

uci set dhcp.cfg01411c.strictorder='1'
uci set dhcp.cfg01411c.filter_aaaa='1'
uci del dhcp.cfg01411c.server
uci add_list dhcp.cfg01411c.server='127.0.0.1#5053'
uci add_list dhcp.cfg01411c.server='127.0.0.1#5054'
uci add_list dhcp.cfg01411c.server='127.0.0.1#5055'
uci add_list dhcp.cfg01411c.server='127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.chatgpt.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.oaistatic.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.oaiusercontent.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.openai.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.microsoft.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.windowsupdate.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.bing.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.supercell.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.seeurlpcl.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.supercellid.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.supercellgames.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.clashroyale.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.brawlstars.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.clash.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.clashofclans.com/127.0.0.1#5056'
uci commit dhcp

echo "Restart service..."

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart
service odhcpd restart

echo "Configure complete..."
