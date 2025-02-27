#!/bin/sh

DIR="/etc/config"
DIR_BACKUP="/root/backup2"
config_files="network
firewall"


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
service podkop disable
service podkop stop

echo "Run and enabled autostart youtubeUnblock..."
service youtubeUnblock enable
service youtubeUnblock start

printf  "\033[32;1mRestart firewall and network...\033[0m\n"
service firewall restart
service network restart

printf  "\033[32;1mOff configured completed...\033[0m"