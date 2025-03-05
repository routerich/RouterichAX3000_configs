# RouterichAX3000_configs

Протестировано на роутере Routerich AX 3000 прошивка OpenWrt 23.05.5 r24106-10cc5fcd00

### Разблокировка сайтов с помощью youtubeUnblock + https-dns-proxy
Разблокировка сайтов с помощью подмены **Hello пакетов DPI** (приложение **youtubeUnblock**) + точечное перенаправление доменов, которые находятся в **геоблоке на ComssDNS** (через перенаправление dnsmasq и пакет **https-dns-proxy**) + добавление правил для **блокировки протокола QUIC** на уровне роутера

Для корректной работы скрипта нужны установленные пакеты **youtubeUnblock** и **https-dns-proxy**

**Установка**
```sh
wget -O - https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main/configure_zaprets.sh | sh
```
**Откат**
```sh
wget -O - https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main/off_configure_zaprets.sh | sh
```

### Разблокировка сайтов с помощью WARP от CloudFlare

**Установка**
```sh
wget --no-check-certificate -O /tmp/awg_config.sh https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main/awg_config.sh && chmod +x /tmp/awg_config.sh && /tmp/awg_config.sh
```
**Откат**
```sh
wget -O - https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/main/off_awg_config.sh | sh
```
