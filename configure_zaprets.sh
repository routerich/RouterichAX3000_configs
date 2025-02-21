#!/bin/sh

URL="https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs/refs/heads/main"
DIR="/etc/config"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"

echo "Upgrade packages..."

opkg update
opkg upgrade youtubeUnblock
opkg upgrade luci-app-youtubeUnblock

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
uci add_list dhcp.cfg01411c.server='/*.x.ai/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.grok.com /127.0.0.1#5056'
uci add dhcp domain # =cfg13f37d
uci set dhcp.@domain[-1].name='chatgpt.com'
uci set dhcp.@domain[-1].ip='94.131.119.85'
uci add dhcp domain # =cfg14f37d
uci set dhcp.@domain[-1].name='openai.com'
uci set dhcp.@domain[-1].ip='94.131.119.85'
uci commit dhcp

echo "Add block QUIC..."

uci add firewall rule # =cfg2492bd
uci set firewall.@rule[-1].name='Block_UDP_80'
uci add_list firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].dest='wan'
uci set firewall.@rule[-1].dest_port='80'
uci set firewall.@rule[-1].target='REJECT'
uci add firewall rule # =cfg2592bd
uci set firewall.@rule[-1].name='Block_UDP_443'
uci add_list firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].dest='wan'
uci set firewall.@rule[-1].dest_port='443'
uci set firewall.@rule[-1].target='REJECT'
uci commit firewall

echo "Crod task add restart service yotubeUnblock..."

cronTask="0 4 * * * service youtubeUnblock restart"
str=$(grep -i "0 4 \* \* \* service youtubeUnblock restart" /etc/crontabs/root)
if [ -z "$str" ] 
then
  echo "$cronTask" >> /etc/crontabs/root
fi

echo "Restart service..."

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart
service odhcpd restart

echo "Configure complete..."
