#!/bin/sh

URL="https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs/refs/heads/main"
DIR="/etc/config"
DIR_BACKUP="/root/backup"
config_files="dhcp
youtubeUnblock
https-dns-proxy"

checkAndAddDomainPermanentName()
{
  nameRule="option name '$1'"
  str=$(grep -i "$nameRule" /etc/config/dhcp)
  if [ -z "$str" ] 
  then 

    uci add dhcp domain
    uci set dhcp.@domain[-1].name="$1"
    uci set dhcp.@domain[-1].ip="$2"
    uci commit dhcp
  fi
}

checkAndAddDomainDnsRedirection()
{
  nameRule="option name '$1'"
  str=$(grep -i "$nameRule" /etc/config/dhcp)
  if [ -z "$str" ] 
  then 

    uci add_list dhcp.cfg01411c.server="$1"
    uci commit dhcp
  fi
}

echo "Upgrade packages..."

opkg update
opkg upgrade youtubeUnblock
opkg upgrade luci-app-youtubeUnblock

if [ ! -d "$DIR_BACKUP" ]
then
  echo "Backup files..."
  mkdir $DIR_BACKUP
  for file in $config_files
  do
    cp -f "$DIR/$file" "$DIR_BACKUP/$file"  
  done
fi

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
uci commit dhcp

checkAndAddDomainDnsRedirection "127.0.0.1#5053"
checkAndAddDomainDnsRedirection "127.0.0.1#5054"
checkAndAddDomainDnsRedirection "127.0.0.1#5055"
checkAndAddDomainDnsRedirection "127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.chatgpt.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.oaistatic.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.oaiusercontent.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.openai.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.microsoft.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.windowsupdate.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.bing.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.supercell.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.seeurlpcl.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.supercellid.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.supercellgames.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.clashroyale.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.brawlstars.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.clash.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.clashofclans.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.x.ai/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.grok.com/127.0.0.1#5056"
checkAndAddDomainDnsRedirection "/*.gitgub.com/127.0.0.1#5056"

echo "Add unblock ChatGPT..."

checkAndAddDomainPermanentName "chatgpt.com" "94.131.119.85"
checkAndAddDomainPermanentName "openai.com" "94.131.119.85"
checkAndAddDomainPermanentName "webrtc.chatgpt.com" "94.131.119.85"
checkAndAddDomainPermanentName "ios.chat.openai.com" "94.131.119.85"
checkAndAddDomainPermanentName "searchgpt.com" "94.131.119.85"

nameRule="option name 'Block_UDP_443'"
str=$(grep -i "$nameRule" /etc/config/firewall)
if [ -z "$str" ] 
then
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
  service firewall restart
fi

cronTask="0 4 * * * wget -O - $URL/configure_zaprets.sh | sh"
str=$(grep -i "0 4 \* \* \* wget -O - $URL/configure_zaprets.sh | sh" /etc/crontabs/root)
if [ -z "$str" ] 
then
  echo "Add cron task auto run configure_zapret..."
  echo "$cronTask" >> /etc/crontabs/root
fi

echo "Restart service..."

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart
service odhcpd restart

echo "Configure complete..."
