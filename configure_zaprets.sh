#!/bin/sh

URL="https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main"
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

install_youtubeunblock_packages() {
    PKGARCH=$(opkg print-architecture | awk 'BEGIN {max=0} {if ($3 > max) {max = $3; arch = $2}} END {print arch}')
    VERSION=$(ubus call system board | jsonfilter -e '@.release.version')
    BASE_URL="https://github.com/Waujito/youtubeUnblock/releases/download/v1.0.0/"
  	PACK_NAME="youtubeUnblock"

    AWG_DIR="/tmp/$PACK_NAME"
    mkdir -p "$AWG_DIR"
    
    if opkg list-installed | grep -q $PACK_NAME; then
        echo "$PACK_NAME already installed"
    else
	    # Список пакетов, которые нужно проверить и установить/обновить
		PACKAGES="kmod-nfnetlink-queue kmod-nft-queue kmod-nf-conntrack"

		for pkg in $PACKAGES; do
			# Проверяем, установлен ли пакет
			if opkg list-installed | grep -q "^$pkg "; then
				echo "$pkg already installed"
			else
				echo "$pkg not installed. Instal..."
				opkg install $pkg
				if [ $? -eq 0 ]; then
					echo "$pkg file installing successfully"
				else
					echo "Error installing $pkg Please, install $pkg manually and run the script again"
					exit 1
				fi
			fi
		done
		
	if [ ! $VERSION = "23.05.5" ]
  	then
  	  echo "Your version $VERSION OpenWRT not support. Please, install $PACK_NAME manually and run the script again"
  	  exit 1
  	fi

        YOUTUBEUNBLOCK_FILENAME="youtubeUnblock-1.0.0-10-f37c3dd-${PKGARCH}-openwrt-23.05.ipk"
        DOWNLOAD_URL="${BASE_URL}${YOUTUBEUNBLOCK_FILENAME}"
		echo $DOWNLOAD_URL
        wget -O "$AWG_DIR/$YOUTUBEUNBLOCK_FILENAME" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "$PACK_NAME file downloaded successfully"
        else
            echo "Error downloading $PACK_NAME. Please, install $PACK_NAME manually and run the script again"
            exit 1
        fi
        
        opkg install "$AWG_DIR/$YOUTUBEUNBLOCK_FILENAME"

        if [ $? -eq 0 ]; then
            echo "$PACK_NAME file installing successfully"
        else
            echo "Error installing $PACK_NAME. Please, install $PACK_NAME manually and run the script again"
            exit 1
        fi
    fi
	
	PACK_NAME="luci-app-youtubeUnblock"
	if opkg list-installed | grep -q $PACK_NAME; then
        echo "$PACK_NAME already installed"
    else
		PACK_NAME="luci-app-youtubeUnblock"
		YOUTUBEUNBLOCK_FILENAME="luci-app-youtubeUnblock-1.0.0-10-f37c3dd.ipk"
        DOWNLOAD_URL="${BASE_URL}${YOUTUBEUNBLOCK_FILENAME}"
		echo $DOWNLOAD_URL
        wget -O "$AWG_DIR/$YOUTUBEUNBLOCK_FILENAME" "$DOWNLOAD_URL"
		
        if [ $? -eq 0 ]; then
            echo "$PACK_NAME file downloaded successfully"
        else
            echo "Error downloading $PACK_NAME. Please, install $PACK_NAME manually and run the script again"
            exit 1
        fi
        
        opkg install "$AWG_DIR/$YOUTUBEUNBLOCK_FILENAME"

        if [ $? -eq 0 ]; then
            echo "$PACK_NAME file installing successfully"
        else
            echo "Error installing $PACK_NAME. Please, install $PACK_NAME manually and run the script again"
            exit 1
        fi
	fi

    rm -rf "$AWG_DIR"
}

checkPackageAndInstall()
{
    local name="$1"
    local isRequried="$2"
    #проверяем установлени ли библиотека $name
    if opkg list-installed | grep -q $name; then
        echo "$name already installed..."
    else
        echo "$name not installed. Installed $name..."
        opkg install $name
		res=$?
		if [ "$isRequried" = "1" ]; then
			if [ $res -eq 0 ]; then
				echo "$name insalled successfully"
			else
				echo "Error installing $name. Please, install $name manually and run the script again"
				exit 1
			fi
		fi
    fi
}

echo "Update list packages..."

opkg update

checkPackageAndInstall "coreutils-base64" "1"

encoded_code="IyEvYmluL3NoCgojINCn0YLQtdC90LjQtSDQvNC+0LTQtdC70Lgg0LjQtyDRhNCw0LnQu9CwCm1vZGVsPSQoY2F0IC90bXAvc3lzaW5mby9tb2RlbCkKCiMg0J/RgNC+0LLQtdGA0LrQsCwg0YHQvtC00LXRgNC20LjRgiDQu9C4INC80L7QtNC10LvRjCDRgdC70L7QstC+ICJSb3V0ZXJpY2giCmlmICEgZWNobyAiJG1vZGVsIiB8IGdyZXAgLXEgIlJvdXRlcmljaCI7IHRoZW4KICAgIGVjaG8gIlRoaXMgc2NyaXB0IGZvciByb3V0ZXJzIFJvdXRlcmljaC4uLiBJZiB5b3Ugd2FudCB0byB1c2UgaXQsIHdyaXRlIHRvIHRoZSBlcCBjaGF0IFRHIEByb3V0ZXJpY2giCiAgICBleGl0IDEKZmk="
eval "$(echo "$encoded_code" | base64 --decode)"

#проверяем установлени ли библиотека https-dns-proxy
checkPackageAndInstall "https-dns-proxy" "1"
checkPackageAndInstall "luci-app-https-dns-proxy" "0"
checkPackageAndInstall "luci-i18n-https-dns-proxy-ru" "0"

install_youtubeunblock_packages

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
manage_package "ruantiblock" "disable" "stop"
manage_package "https-dns-proxy" "enable" "start"
manage_package "youtubeUnblock" "enable" "start"

echo "Restart service..."

service youtubeUnblock restart
service https-dns-proxy restart
service dnsmasq restart
service odhcpd restart

printf  "\033[32;1mConfigured completed...\033[0m\n"
