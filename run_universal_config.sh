#!/bin/sh

VERSION=$(ubus call system board | jsonfilter -e '@.release.description')

if echo "$VERSION" | grep -qi 'RouteRich'; then
	printf "\033[32;1mThis new firmware. Running new scprit...\033[0m\n"
	wget --no-check-certificate -O /tmp/universal_config_new_podkop.sh https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/beta_alt_test/universal_config_new_podkop.sh && chmod +x /tmp/universal_config_new_podkop.sh && /tmp/universal_config_new_podkop.sh $1 $2
else
	printf "\033[32;1mThis old firmware.\nRecommendation, upgrade firmware to actual release...\nSleep 5 sec...\033[0m\n"
	sleep 5
	printf "\033[32;1mRunning old scprit...\033[0m\n"
	wget --no-check-certificate -O /tmp/universal_config.sh https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/beta_alt_test/universal_config.sh && chmod +x /tmp/universal_config.sh && /tmp/universal_config.sh $1 $2
fi