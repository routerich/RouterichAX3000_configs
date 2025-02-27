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

manage_package() {
    local name="$1"
    local autostart="$2"
    local process="$3"

    # Проверка, установлен ли пакет
    if opkg list-installed | grep -q "^$name"; then
        
        # Проверка, включен ли автозапуск
        if /etc/init.d/$name enabled; then
            if [ "$autostart" = "disable" ]; then
                /etc/init.d/$name disable
            fi
        else
            if [ "$autostart" = "enable" ]; then
                /etc/init.d/$name enable
            fi
        fi

        # Проверка, запущен ли процесс
        if pidof $name > /dev/null; then
            if [ "$process" = "stop" ]; then
                /etc/init.d/$name stop
            fi
        else
            if [ "$process" = "start" ]; then
                /etc/init.d/$name start
            fi
        fi
    fi
}

echo "Upgrade packages..."

opkg update
opkg upgrade youtubeUnblock
opkg upgrade luci-app-youtubeUnblock

if [ ! -d "$DIR_BACKUP" ]
then
  echo "Backup files..."
  mkdir -p $DIR_BACKUP
  for file in $config_files
  do
    cp -f "$DIR/$file" "$DIR_BACKUP/$file"  
  done

  echo "Replace configs..."

  for file in $config_files
  do
    if [ "$file" != "dhcp" ] 
    then 
      wget -O "$DIR/$file" "$URL/config_files/$file" 
    fi
  done
fi

echo "Configure dhcp..."

uci set dhcp.cfg01411c.strictorder='1'
uci set dhcp.cfg01411c.filter_aaaa='1'
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
uci add_list dhcp.cfg01411c.server='/*.grok.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.github.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.forzamotorsport.net/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.forzaracingchampionship.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.forzarc.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.gamepass.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.orithegame.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.renovacionxboxlive.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.tellmewhygame.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.co/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.org/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.co/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.org/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxab.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxgamepass.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxgamestudios.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxlive.cn/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxlive.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxone.co/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxone.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxone.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxplayanywhere.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxservices.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxstudios.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbx.lv/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.sentry.io/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.usercentrics.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.recaptcha.net/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.gstatic.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.brawlstarsgame.com/127.0.0.1#5056'
uci commit dhcp

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

manage_package "podkop" "disable" "stop"

echo "Restart service..."

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart
service odhcpd restart

printf  "\033[32;1mConfigured completed...\033[0m"
