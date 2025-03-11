#!/bin/sh

DIR="/etc/config"
DIR_BACKUP="/root/backup2"
config_files="network
firewall
https-dns-proxy
dhcp"

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

if [ -d "$DIR_BACKUP" ]
then
    echo "Restore configs..."
    for file in $config_files
    do
        cp -f "$DIR_BACKUP/$file" "$DIR/$file"   
    done

    rm -rf "$DIR_BACKUP"
fi

echo "Stop and disabled autostart Podkop..."
manage_package "podkop" "disable" "stop"

echo "Run and enabled autostart youtubeUnblock and ruantiblock..."
manage_package "youtubeUnblock" "enable" "start"
manage_package "ruantiblock" "enable" "start"

printf  "\033[32;1mRestart firewall, dnsmasq, odhcpd...\033[0m\n"
service firewall restart
service dnsmasq restart
service odhcpd restart
#service network restart

printf  "\033[32;1mOff configured completed...\033[0m\n"
