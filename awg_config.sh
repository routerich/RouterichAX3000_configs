#!/bin/sh

#запрос конфигурации WARP
result=$(curl 'https://warp.llimonix.pw/api/warp' \
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

#проверяем установлени ли библиотека jq
test_json=$(echo "{ }" | jq)
if [ "$test_json" != "{}" ]; then
        echo "jq not installed"
        opkg update
        opkg install jq
fi

#парсим результат запроса конфигурации WARP
content=$(echo $result | jq '.content')
configBase64=$(echo $content | jq -r '.configBase64')
#echo "$result"
warp_config=$(echo "$configBase64" | base64 -d)
#echo "$warp_config"
while IFS=' = ' read -r line; do
    if echo "$line" | grep -q "="; then
        # Разделяем строку по первому вхождению "="
        key=$(echo "$line" | cut -d'=' -f1 | xargs)  # Убираем пробелы
        value=$(echo "$line" | cut -d'=' -f2- | xargs)  # Убираем пробелы
        eval "$key=\"$value\""
	fi
done < <(echo "$warp_config")

Address=$(echo "$Address" | cut -d',' -f1)
DNS=$(echo "$DNS" | cut -d',' -f1)
AllowedIPs=$(echo "$AllowedIPs" | cut -d',' -f1)
EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)

#выводим результат
echo "PrivateKey: $PrivateKey"
echo "S1: $S1"
echo "S2: $S2"
echo "Jc: $Jc"
echo "Jmin: $Jmin"
echo "Jmax: $Jmax"
echo "H1: $H1"
echo "H2: $H2"
echo "H3: $H3"
echo "H4: $H4"
echo "MTU: $MTU"
echo "Address: $Address"
echo "DNS: $DNS"
echo "PublicKey: $PublicKey"
echo "AllowedIPs: $AllowedIPs"
echo "Endpoint: $Endpoint"
echo "EndpointIP: $EndpointIP"
echo "EndpointPort: $EndpointPort"


INTERFACE_NAME="awg_route0"
CONFIG_NAME="amneziawg_awg_route0"
PROTO="amneziawg"
ZONE_NAME="awg"

uci set network.${INTERFACE_NAME}=interface
uci set network.${INTERFACE_NAME}.proto=$PROTO
uci set network.${INTERFACE_NAME}.private_key=$PrivateKey
uci set network.${INTERFACE_NAME}.listen_port='51821'
uci set network.${INTERFACE_NAME}.addresses=$Address
uci set network.${INTERFACE_NAME}.awg_jc=$Jc
uci set network.${INTERFACE_NAME}.awg_jmin=$Jmin
uci set network.${INTERFACE_NAME}.awg_jmax=$Jmax
uci set network.${INTERFACE_NAME}.awg_s1=$S1
uci set network.${INTERFACE_NAME}.awg_s2=$S2
uci set network.${INTERFACE_NAME}.awg_h1=$H1
uci set network.${INTERFACE_NAME}.awg_h2=$H2
uci set network.${INTERFACE_NAME}.awg_h3=$H3
uci set network.${INTERFACE_NAME}.awg_h4=$H4
uci set network.${INTERFACE_NAME}.mtu=$MTU

if ! uci show network | grep -q ${CONFIG_NAME}; then
	uci add network ${CONFIG_NAME}
fi

uci set network.@${CONFIG_NAME}[0]=$CONFIG_NAME
uci set network.@${CONFIG_NAME}[0].name="${INTERFACE_NAME}_client"
uci set network.@${CONFIG_NAME}[0].public_key=$PublicKey
uci set network.@${CONFIG_NAME}[0].route_allowed_ips='0'
uci set network.@${CONFIG_NAME}[0].persistent_keepalive='25'
uci set network.@${CONFIG_NAME}[0].endpoint_host=$EndpointIP
uci set network.@${CONFIG_NAME}[0].allowed_ips='0.0.0.0/0'
uci set network.@${CONFIG_NAME}[0].endpoint_port=$EndpointPort
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
	uci set firewall.@forwarding[-1].name="${ZONE_NAME}-lan"
	uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
	uci set firewall.@forwarding[-1].src='lan'
	uci set firewall.@forwarding[-1].family='ipv4'
	uci commit firewall
fi

service firewall restart
service network restart


#opkg remove luci-app-podkop podkop luci-i18n-podkop-ru
#wget --no-check-certificate -O /tmp/autoinstall.sh https://raw.githubusercontent.com/CodeRoK7/podkop-v0.2.5/refs/heads/main/install.sh && chmod +x /tmp/autoinstall.sh && printf '%s\n' 2 2 Y Y Y | /tmp/autoinstall.sh