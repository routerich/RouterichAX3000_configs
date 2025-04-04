#!/bin/sh

install_awg_packages() {
    # Получение pkgarch с наибольшим приоритетом
    PKGARCH=$(opkg print-architecture | awk 'BEGIN {max=0} {if ($3 > max) {max = $3; arch = $2}} END {print arch}')

    TARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 1)
    SUBTARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 2)
    VERSION=$(ubus call system board | jsonfilter -e '@.release.version')
    PKGPOSTFIX="_v${VERSION}_${PKGARCH}_${TARGET}_${SUBTARGET}.ipk"
    BASE_URL="https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/"

    AWG_DIR="/tmp/amneziawg"
    mkdir -p "$AWG_DIR"
    
    if opkg list-installed | grep -q kmod-amneziawg; then
        echo "kmod-amneziawg already installed"
    else
        KMOD_AMNEZIAWG_FILENAME="kmod-amneziawg${PKGPOSTFIX}"
        DOWNLOAD_URL="${BASE_URL}v${VERSION}/${KMOD_AMNEZIAWG_FILENAME}"
        wget -O "$AWG_DIR/$KMOD_AMNEZIAWG_FILENAME" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "kmod-amneziawg file downloaded successfully"
        else
            echo "Error downloading kmod-amneziawg. Please, install kmod-amneziawg manually and run the script again"
            exit 1
        fi
        
        opkg install "$AWG_DIR/$KMOD_AMNEZIAWG_FILENAME"

        if [ $? -eq 0 ]; then
            echo "kmod-amneziawg file downloaded successfully"
        else
            echo "Error installing kmod-amneziawg. Please, install kmod-amneziawg manually and run the script again"
            exit 1
        fi
    fi

    if opkg list-installed | grep -q amneziawg-tools; then
        echo "amneziawg-tools already installed"
    else
        AMNEZIAWG_TOOLS_FILENAME="amneziawg-tools${PKGPOSTFIX}"
        DOWNLOAD_URL="${BASE_URL}v${VERSION}/${AMNEZIAWG_TOOLS_FILENAME}"
        wget -O "$AWG_DIR/$AMNEZIAWG_TOOLS_FILENAME" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "amneziawg-tools file downloaded successfully"
        else
            echo "Error downloading amneziawg-tools. Please, install amneziawg-tools manually and run the script again"
            exit 1
        fi

        opkg install "$AWG_DIR/$AMNEZIAWG_TOOLS_FILENAME"

        if [ $? -eq 0 ]; then
            echo "amneziawg-tools file downloaded successfully"
        else
            echo "Error installing amneziawg-tools. Please, install amneziawg-tools manually and run the script again"
            exit 1
        fi
    fi
    
    if opkg list-installed | grep -q luci-app-amneziawg; then
        echo "luci-app-amneziawg already installed"
    else
        LUCI_APP_AMNEZIAWG_FILENAME="luci-app-amneziawg${PKGPOSTFIX}"
        DOWNLOAD_URL="${BASE_URL}v${VERSION}/${LUCI_APP_AMNEZIAWG_FILENAME}"
        wget -O "$AWG_DIR/$LUCI_APP_AMNEZIAWG_FILENAME" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "luci-app-amneziawg file downloaded successfully"
        else
            echo "Error downloading luci-app-amneziawg. Please, install luci-app-amneziawg manually and run the script again"
            exit 1
        fi

        opkg install "$AWG_DIR/$LUCI_APP_AMNEZIAWG_FILENAME"

        if [ $? -eq 0 ]; then
            echo "luci-app-amneziawg file downloaded successfully"
        else
            echo "Error installing luci-app-amneziawg. Please, install luci-app-amneziawg manually and run the script again"
            exit 1
        fi
    fi

    rm -rf "$AWG_DIR"
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

requestConfWARP1()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://warp.llimonix.pw/api/warp' \
	  -H 'Accept: */*' \
	  -H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
	  -H 'Connection: keep-alive' \
	  -H 'Content-Type: application/json' \
	  -H 'Origin: https://warp.llimonix.pw' \
	  -H 'Referer: https://warp.llimonix.pw/' \
	  -H 'Sec-Fetch-Dest: empty' \
	  -H 'Sec-Fetch-Mode: cors' \
	  -H 'Sec-Fetch-Site: same-origin' \
	  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
	  -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133")' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Windows"' \
	  --data-raw '{"selectedServices":[],"siteMode":"all","deviceType":"computer"}')
	echo "$result"
}

requestConfWARP2()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://topor-warp.vercel.app/generate' \
	  -H 'Accept: */*' \
	  -H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
	  -H 'Connection: keep-alive' \
	  -H 'Content-Type: application/json' \
	  -H 'Origin: https://topor-warp.vercel.app' \
	  -H 'Referer: https://topor-warp.vercel.app/' \
	  -H 'Sec-Fetch-Dest: empty' \
	  -H 'Sec-Fetch-Mode: cors' \
	  -H 'Sec-Fetch-Site: same-origin' \
	  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
	  -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Windows"' \
	  --data-raw '{"platform":"all"}')
	echo "$result"
}

requestConfWARP3()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://warp-gen.vercel.app/generate-config' \
		-H 'Accept: */*' \
		-H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
		-H 'Connection: keep-alive' \
		-H 'Referer: https://warp-gen.vercel.app/' \
		-H 'Sec-Fetch-Dest: empty' \
		-H 'Sec-Fetch-Mode: cors' \
		-H 'Sec-Fetch-Site: same-origin' \
		-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
		-H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
		-H 'sec-ch-ua-mobile: ?0' \
		-H 'sec-ch-ua-platform: "Windows"')
	echo "$result"
}

requestConfWARP4()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp' \
	  -H 'Accept: */*' \
	  -H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
	  -H 'Connection: keep-alive' \
	  -H 'Referer: https://config-generator-warp.vercel.app/' \
	  -H 'Sec-Fetch-Dest: empty' \
	  -H 'Sec-Fetch-Mode: cors' \
	  -H 'Sec-Fetch-Site: same-origin' \
	  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
	  -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Windows"')
	echo "$result"
}

# Функция для обработки выполнения запроса
check_request() {
    local response="$1"
	local choice="$2"
	
    # Извлекаем код состояния
    response_code="${response: -3}"  # Последние 3 символа - это код состояния
    response_body="${response%???}"    # Все, кроме последних 3 символов - это тело ответа
    #echo $response_body
	#echo $response_code
    # Проверяем код состояния
    if [ "$response_code" -eq 200 ]; then
		case $choice in
		1)
			status=$(echo $response_body | jq '.success')
			#echo "$status"
			if [ "$status" = "true" ]
			then
				content=$(echo $response_body | jq '.content')
				configBase64=$(echo $content | jq -r '.configBase64')
				warpGen=$(echo "$configBase64" | base64 -d)
				echo "$warpGen";
			else
				echo "Error"
			fi
            ;;
		2)
			echo "$response_body"
            ;;
		3)
			content=$(echo $response_body | jq -r '.config')
			#content=$(echo "$content" | sed 's/\\n/\012/g')
			echo "$content"
            ;;
		4)
			content=$(echo $response_body | jq -r '.content')  
            warp_config=$(echo "$content" | base64 -d)
            echo "$warp_config"
            ;;
		*)
			echo "Error"
		esac
	else
		echo "Error"
	fi
}

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

echo "Update list packages..."
opkg update

checkPackageAndInstall "coreutils-base64" "1"

encoded_code="IyEvYmluL3NoCgojINCn0YLQtdC90LjQtSDQvNC+0LTQtdC70Lgg0LjQtyDRhNCw0LnQu9CwCm1vZGVsPSQoY2F0IC90bXAvc3lzaW5mby9tb2RlbCkKCiMg0J/RgNC+0LLQtdGA0LrQsCwg0YHQvtC00LXRgNC20LjRgiDQu9C4INC80L7QtNC10LvRjCDRgdC70L7QstC+ICJSb3V0ZXJpY2giCmlmICEgZWNobyAiJG1vZGVsIiB8IGdyZXAgLXEgIlJvdXRlcmljaCI7IHRoZW4KICAgIGVjaG8gIlRoaXMgc2NyaXB0IGZvciByb3V0ZXJzIFJvdXRlcmljaC4uLiBJZiB5b3Ugd2FudCB0byB1c2UgaXQsIHdyaXRlIHRvIHRoZSBlcCBjaGF0IFRHIEByb3V0ZXJpY2giCiAgICBleGl0IDEKZmk="
eval "$(echo "$encoded_code" | base64 --decode)"

#проверка и установка пакетов AmneziaWG
install_awg_packages

checkPackageAndInstall "jq" "1"
checkPackageAndInstall "curl" "1"
checkPackageAndInstall "unzip" "1"
checkPackageAndInstall "sing-box" "1"

#проверяем установлени ли пакет dnsmasq-full
if opkg list-installed | grep -q dnsmasq-full; then
	echo "dnsmasq-full already installed..."
else
	echo "Installed dnsmasq-full..."
	cd /tmp/ && opkg download dnsmasq-full
	opkg remove dnsmasq && opkg install dnsmasq-full --cache /tmp/

	[ -f /etc/config/dhcp-opkg ] && cp /etc/config/dhcp /etc/config/dhcp-old && mv /etc/config/dhcp-opkg /etc/config/dhcp
fi

printf "Setting confdir dnsmasq"
uci set dhcp.@dnsmasq[0].confdir='/tmp/dnsmasq.d'
uci commit dhcp

DIR="/etc/config"
DIR_BACKUP="/root/backup3"
config_files="network
firewall
https-dns-proxy
youtubeUnblock
dhcp"
URL="https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main"

checkPackageAndInstall "https-dns-proxy" "0"

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
		if [ "$file" == "https-dns-proxy" ] 
		then 
		  wget -O "$DIR/$file" "$URL/config_files/$file" 
		fi
	done
fi

echo "Configure dhcp..."

uci set dhcp.cfg01411c.strictorder='1'
uci set dhcp.cfg01411c.filter_aaaa='1'
uci commit dhcp

echo "Install opera-proxy client..."
service stop vpn > /dev/null
rm -f /usr/bin/vpns /etc/init.d/vpn

url="https://github.com/NitroOxid/openwrt-opera-proxy-bin/releases/download/1.8.0/opera-proxy_1.8.0-1_aarch64_cortex-a53.ipk"
destination_file="/tmp/opera-proxy.ipk"

echo "Downloading opera-proxy..."
wget "$url" -O "$destination_file" || { echo "Failed to download the file"; exit 1; }
echo "Installing opera-proxy..."
opkg install $destination_file

cat <<EOF > /etc/sing-box/config.json
  {
    "log": {
    "disabled": true,
    "level": "error"
  },
  "inbounds": [
    {
      "type": "tproxy",
      "listen": "::",
      "listen_port": 1100,
      "sniff": false
    }
  ],
  "outbounds": [
    {
      "type": "http",
      "server": "127.0.0.1",
      "server_port": 18080
    }
  ],
  "route": {
    "auto_detect_interface": true
  }
}
EOF

echo "Setting sing-box..."
uci set sing-box.main.enabled='1'
uci set sing-box.main.user='root'
uci commit sing-box

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
fi

printf "\033[32;1mAutomatic generate config AmneziaWG WARP (n) or manual input parameters for AmneziaWG (y)...\033[0m\n"
countRepeatAWGGen=5
echo "Input manual parameters AmneziaWG? (y/n): "
read is_manual_input_parameters
currIter=0
isExit=0
while [ $currIter -lt $countRepeatAWGGen ] && [ "$isExit" = "0" ]
do
	currIter=$(( $currIter + 1 ))
	printf "\033[32;1mCreate and Check AWG WARP... Attempt #$currIter... Please wait...\033[0m\n"
	if [ "$is_manual_input_parameters" = "y" ] || [ "$is_manual_input_parameters" = "Y" ]
	then
		read -r -p "Enter the private key (from [Interface]):"$'\n' PrivateKey
		read -r -p "Enter S1 value (from [Interface]):"$'\n' S1
		read -r -p "Enter S2 value (from [Interface]):"$'\n' S2
		read -r -p "Enter Jc value (from [Interface]):"$'\n' Jc
		read -r -p "Enter Jmin value (from [Interface]):"$'\n' Jmin
		read -r -p "Enter Jmax value (from [Interface]):"$'\n' Jmax
		read -r -p "Enter H1 value (from [Interface]):"$'\n' H1
		read -r -p "Enter H2 value (from [Interface]):"$'\n' H2
		read -r -p "Enter H3 value (from [Interface]):"$'\n' H3
		read -r -p "Enter H4 value (from [Interface]):"$'\n' H4
		
		while true; do
			read -r -p "Enter internal IP address with subnet, example 192.168.100.5/24 (from [Interface]):"$'\n' Address
			if echo "$Address" | egrep -oq '^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]+)?$'; then
				break
			else
				echo "This IP is not valid. Please repeat"
			fi
		done

		read -r -p "Enter the public key (from [Peer]):"$'\n' PublicKey
		read -r -p "Enter Endpoint host without port (Domain or IP) (from [Peer]):"$'\n' EndpointIP
		read -r -p "Enter Endpoint host port (from [Peer]) [51820]:"$'\n' EndpointPort

		DNS="1.1.1.1"
		MTU=1280
		AllowedIPs="0.0.0.0/0"
		isExit=1
	else
		warp_config="Error"
		printf "\033[32;1mRequest WARP config... Attempt #1\033[0m\n"
		result=$(requestConfWARP1)
		warpGen=$(check_request "$result" 1)
		if [ "$warpGen" = "Error" ]
		then
			printf "\033[32;1mRequest WARP config... Attempt #2\033[0m\n"
			result=$(requestConfWARP2)
			warpGen=$(check_request "$result" 2)
			if [ "$warpGen" = "Error" ]
			then
				printf "\033[32;1mRequest WARP config... Attempt #3\033[0m\n"
				result=$(requestConfWARP3)
				warpGen=$(check_request "$result" 3)
				if [ "$warpGen" = "Error" ]
				then
					printf "\033[32;1mRequest WARP config... Attempt #4\033[0m\n"
					result=$(requestConfWARP4)
					warpGen=$(check_request "$result" 4)
					if [ "$warpGen" = "Error" ]
					then
						warp_config="Error"
					else
						warp_config=$warpGen
					fi
				else
					warp_config=$warpGen
				fi
			else
				warp_config=$warpGen
			fi
		else
			warp_config=$warpGen
		fi
		
		if [ "$warp_config" = "Error" ] 
		then
			printf "\033[32;1mGenerate config AWG WARP failed...Try again later...\033[0m\n"
			isExit=2
			#exit 1
		else
			while IFS=' = ' read -r line; do
			if echo "$line" | grep -q "="; then
				# Разделяем строку по первому вхождению "="
				key=$(echo "$line" | cut -d'=' -f1 | xargs)  # Убираем пробелы
				value=$(echo "$line" | cut -d'=' -f2- | xargs)  # Убираем пробелы
				#echo "key = $key, value = $value"
				eval "$key=\"$value\""
			fi
			done < <(echo "$warp_config")

			#вытаскиваем нужные нам данные из распарсинного ответа
			Address=$(echo "$Address" | cut -d',' -f1)
			DNS=$(echo "$DNS" | cut -d',' -f1)
			AllowedIPs=$(echo "$AllowedIPs" | cut -d',' -f1)
			EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
			EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)
		fi
	fi
	
	if [ "$isExit" = "2" ] 
	then
		isExit=0
	else
		printf "\033[32;1mCreate and configure tunnel AmneziaWG WARP...\033[0m\n"

		#задаём имя интерфейса
		INTERFACE_NAME="awg10"
		CONFIG_NAME="amneziawg_awg10"
		PROTO="amneziawg"
		ZONE_NAME="awg"

		uci set network.${INTERFACE_NAME}=interface
		uci set network.${INTERFACE_NAME}.proto=$PROTO
		if ! uci show network | grep -q ${CONFIG_NAME}; then
			uci add network ${CONFIG_NAME}
		fi
		uci set network.${INTERFACE_NAME}.private_key=$PrivateKey
		uci del network.${INTERFACE_NAME}.addresses
		uci add_list network.${INTERFACE_NAME}.addresses=$Address
		uci set network.${INTERFACE_NAME}.mtu=$MTU
		uci set network.${INTERFACE_NAME}.awg_jc=$Jc
		uci set network.${INTERFACE_NAME}.awg_jmin=$Jmin
		uci set network.${INTERFACE_NAME}.awg_jmax=$Jmax
		uci set network.${INTERFACE_NAME}.awg_s1=$S1
		uci set network.${INTERFACE_NAME}.awg_s2=$S2
		uci set network.${INTERFACE_NAME}.awg_h1=$H1
		uci set network.${INTERFACE_NAME}.awg_h2=$H2
		uci set network.${INTERFACE_NAME}.awg_h3=$H3
		uci set network.${INTERFACE_NAME}.awg_h4=$H4
		uci set network.${INTERFACE_NAME}.nohostroute='1'
		
		uci set network.@${CONFIG_NAME}[-1].description="${INTERFACE_NAME}_peer"
		uci set network.@${CONFIG_NAME}[-1].public_key=$PublicKey
		uci set network.@${CONFIG_NAME}[-1].endpoint_host=$EndpointIP
		uci set network.@${CONFIG_NAME}[-1].endpoint_port=$EndpointPort
		uci set network.@${CONFIG_NAME}[-1].persistent_keepalive='25'
		uci set network.@${CONFIG_NAME}[-1].allowed_ips='0.0.0.0/0'
		uci set network.@${CONFIG_NAME}[-1].route_allowed_ips='0'
		uci commit network

		if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
			printf "\033[32;1mZone Create\033[0m\n"
			uci add firewall zone
			uci set firewall.@zone[-1].name=$ZONE_NAME
			uci set firewall.@zone[-1].network=$INTERFACE_NAME
			uci set firewall.@zone[-1].forward='REJECT'
			uci set firewall.@zone[-1].output='ACCEPT'
			uci set firewall.@zone[-1].input='REJECT'
			uci set firewall.@zone[-1].masq='1'
			uci set firewall.@zone[-1].mtu_fix='1'
			uci set firewall.@zone[-1].family='ipv4'
			uci commit firewall
		fi

		if ! uci show firewall | grep -q "@forwarding.*name='${ZONE_NAME}'"; then
			printf "\033[32;1mConfigured forwarding\033[0m\n"
			uci add firewall forwarding
			uci set firewall.@forwarding[-1]=forwarding
			uci set firewall.@forwarding[-1].name="${ZONE_NAME}"
			uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
			uci set firewall.@forwarding[-1].src='lan'
			uci set firewall.@forwarding[-1].family='ipv4'
			uci commit firewall
		fi

		# Получаем список всех зон
		ZONES=$(uci show firewall | grep "zone$" | cut -d'=' -f1)
		#echo $ZONES
		# Циклически проходим по всем зонам
		for zone in $ZONES; do
		# Получаем имя зоны
		CURR_ZONE_NAME=$(uci get $zone.name)
		#echo $CURR_ZONE_NAME
		# Проверяем, является ли это зона с именем "$ZONE_NAME"
		if [ "$CURR_ZONE_NAME" = "$ZONE_NAME" ]; then
			# Проверяем, существует ли интерфейс в зоне
			if ! uci get $zone.network | grep -q "$INTERFACE_NAME"; then
			# Добавляем интерфейс в зону
			uci add_list $zone.network="$INTERFACE_NAME"
			uci commit firewall
			#echo "Интерфейс '$INTERFACE_NAME' добавлен в зону '$ZONE_NAME'"
			fi
		fi
		done
		if [ "$currIter" = "1" ]
		then
			service firewall restart
		fi
		#service firewall restart
		#service network restart

		# Отключаем интерфейс
		ifdown $INTERFACE_NAME
		# Включаем интерфейс
		ifup $INTERFACE_NAME
		printf "\033[32;1mWait up AWG WARP 10 second...\033[0m\n"
		sleep 10
		
		pingAddress="8.8.8.8"
		if ping -c 1 -I $INTERFACE_NAME $pingAddress >/dev/null 2>&1
		then
			isExit=1
		else
			isExit=0
		fi
	fi
done

varByPass=0

if [ "$isExit" = "1" ]
then
	printf "\033[32;1mAWG WARP well work...\033[0m\n"
	varByPass=1
else
    printf "\033[32;1mAWG WARP not work...Try work youtubeunblock...Please wait...\033[0m\n"
	install_youtubeunblock_packages
	opkg upgrade youtubeUnblock
	opkg upgrade luci-app-youtubeUnblock
    manage_package "youtubeUnblock" "enable" "start"
	wget -O "/etc/config/youtubeUnblock" "$URL/config_files/youtubeUnblockSecond"
	service youtubeUnblock restart
	curl -f -o /dev/null -k --connect-to ::google.com -L -H "Host: mirror.gcr.io" --max-time 360 https://test.googlevideo.com/v2/cimg/android/blobs/sha256:6fd8bdac3da660bde7bd0b6f2b6a46e1b686afb74b9a4614def32532b73f5eaa

	# Проверяем код выхода
	if [ $? -eq 0 ]; then
		printf "\033[32;1myoutubeUnblock well work...\033[0m\n"
		varByPass=2
	else
		manage_package "youtubeUnblock" "disable" "stop"
		printf "\033[32;1myoutubeUnblock not work...Try opera proxy...\033[0m\n"
		service sing-box restart
		sing-box tools fetch ifconfig.co -D /etc/sing-box/
		if [ $? -eq 0 ]; then
			printf "\033[32;1mOpera proxy well work...\033[0m\n"
			varByPass=3
		else
			printf "\033[32;1mOpera proxy not work...Try custom settings router to bypass the locks... Recomendation buy 'VPS' and up 'vless'\033[0m\n"
			exit 1
		fi
	fi
fi

printf  "\033[32;1mRestart service dnsmasq, odhcpd...\033[0m\n"
service dnsmasq restart
service odhcpd restart

path_podkop_config="/etc/config/podkop"
path_podkop_config_backup="/root/podkop"
URL="https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main"

case $varByPass in
1)
	nameFileReplacePodkop="podkop"
	printf  "\033[32;1mStop and disabled service 'youtubeUnblock' and 'ruantiblock'...\033[0m\n"
	manage_package "youtubeUnblock" "disable" "stop"
	manage_package "ruantiblock" "disable" "stop"
	;;
2)
	nameFileReplacePodkop="podkopSecond"
	printf  "\033[32;1mStop and disabled service 'ruantiblock'...\033[0m\n"
	manage_package "ruantiblock" "disable" "stop"
	;;
3)
	nameFileReplacePodkop="podkopSecondYoutube"
	printf  "\033[32;1mStop and disabled service 'youtubeUnblock' and 'ruantiblock'...\033[0m\n"
	manage_package "youtubeUnblock" "disable" "stop"
	manage_package "ruantiblock" "disable" "stop"
	;;
*)
	nameFileReplacePodkop="podkop"
esac

PACKAGE="podkop"
REQUIRED_VERSION="0.2.5-1"

INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
if [ -n "$INSTALLED_VERSION" ] && [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
    echo "Version package $PACKAGE not equal $REQUIRED_VERSION. Removed packages..."
    opkg remove --force-removal-of-dependent-packages $PACKAGE
fi

if [ -f "/etc/init.d/podkop" ]; then
	printf "Podkop installed. Reconfigured on AWG WARP and Opera Proxy? (y/n): \n"
	is_reconfig_podkop="y"
	read is_reconfig_podkop
	if [ "$is_reconfig_podkop" = "y" ] || [ "$is_reconfig_podkop" = "Y" ]; then
		cp -f "$path_podkop_config" "$path_podkop_config_backup"
		wget -O "$path_podkop_config" "$URL/config_files/$nameFileReplacePodkop" 
		echo "Backup of your config in path '$path_podkop_config_backup'"
		echo "Podkop reconfigured..."
	fi
else
	printf "\033[32;1mInstall and configure PODKOP (a tool for point routing of traffic)?? (y/n): \033[0m\n"
	is_install_podkop="y"
	read is_install_podkop

	if [ "$is_install_podkop" = "y" ] || [ "$is_install_podkop" = "Y" ]; then
		DOWNLOAD_DIR="/tmp/podkop"
		mkdir -p "$DOWNLOAD_DIR"
		podkop_files="podkop_0.2.5-1_all.ipk
			luci-app-podkop_0.2.5_all.ipk
			luci-i18n-podkop-ru_0.2.5.ipk"
		for file in $podkop_files
		do
			echo "Download $file..."
			wget -q -O "$DOWNLOAD_DIR/$file" "$URL/podkop_packets/$file"
		done
		opkg install $DOWNLOAD_DIR/podkop*.ipk
		opkg install $DOWNLOAD_DIR/luci-app-podkop*.ipk
		opkg install $DOWNLOAD_DIR/luci-i18n-podkop-ru*.ipk
		rm -f $DOWNLOAD_DIR/podkop*.ipk $DOWNLOAD_DIR/luci-app-podkop*.ipk $DOWNLOAD_DIR/luci-i18n-podkop-ru*.ipk
		wget -O "$path_podkop_config" "$URL/config_files/$nameFileReplacePodkop" 
		echo "Podkop installed.."
	fi
fi

printf  "\033[32;1mStart and enable service 'https-dns-proxy'...\033[0m\n"
manage_package "https-dns-proxy" "enable" "start"

str=$(grep -i "0 4 \* \* \* wget -O - $URL/configure_zaprets.sh | sh" /etc/crontabs/root)
if [ ! -z "$str" ]
then
	grep -v "0 4 \* \* \* wget -O - $URL/configure_zaprets.sh | sh" /etc/crontabs/root > /etc/crontabs/temp
	cp -f "/etc/crontabs/temp" "/etc/crontabs/root"
	rm -f "/etc/crontabs/temp"
fi

#printf  "\033[32;1mRestart firewall and network...\033[0m\n"
#service firewall restart
#service network restart

# Отключаем интерфейс
#ifdown $INTERFACE_NAME
# Ждем несколько секунд (по желанию)
#sleep 2
# Включаем интерфейс
#ifup $INTERFACE_NAME

printf  "\033[32;1mService Podkop and Sing-Box restart...\033[0m\n"
service sing-box enable
service sing-box restart
service podkop enable
service podkop restart

printf  "\033[32;1mConfigured completed...\033[0m\n"
