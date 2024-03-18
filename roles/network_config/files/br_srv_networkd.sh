#!/bin/bash

# Устанавливаем IPv4 и IPv6 адреса и их маски подсетей
IPV4_ADDRESS="172.16.0.42/28"
IPV6_ADDRESS="172:16:E::A/124"

# Выбираем сетевой интерфейс (предположим, что он называется ens36)
NETWORK_INTERFACE="ens36"

# Получаем текущий IPv4 и IPv6 адреса сетевого интерфейса
CURRENT_IPV4=$(nmcli -g IP4.ADDRESS dev show "$NETWORK_INTERFACE")
CURRENT_IPV6=$(nmcli -g IP6.ADDRESS dev show "$NETWORK_INTERFACE")

# Проверяем, был ли изменен IPv4 или IPv6 адрес
if [ "$CURRENT_IPV4" != "$IPV4_ADDRESS" ] || [ "$CURRENT_IPV6" != "$IPV6_ADDRESS" ]; then
    echo "IP addresses have been changed or connection does not exist. Removing old connection..."
    nmcli con delete "$NETWORK_INTERFACE"
elif [ "$CURRENT_IPV4" = "$IPV4_ADDRESS" ] && [ "$CURRENT_IPV6" = "$IPV6_ADDRESS" ]; then
    echo "IP addresses are already assigned and have not changed. Skipping..."
    exit 0
fi

# Создаем новое соединение для интерфейса ens36
nmcli con add con-name "$NETWORK_INTERFACE" ifname "$NETWORK_INTERFACE" type ethernet ip4 "$IPV4_ADDRESS" ip6 "$IPV6_ADDRESS" gw4 "$GATEWAY"

# Активируем соединение
nmcli con up "$NETWORK_INTERFACE"

# Завершаем выполнение скрипта
exit
