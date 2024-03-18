#!/bin/bash

# Получаем список активных сетевых интерфейсов (кроме loopback)
interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | awk '{print $1}' | grep -P '^(ens36|ens37)')

# Переменная, показывающая, был ли найден активный интерфейс
interface_found=0

# DNS-серверы
DNS_SERVERS=(
    "131.131.0.60"
    "131:131:d::6"
)

# Проходим по каждому интерфейсу и проверяем его состояние
for interface in $interfaces; do
    state=$(cat /sys/class/net/$interface/operstate)
    if [[ "$state" == "up" ]]; then
        # Устанавливаем IPv4 и IPv6 адреса и их маски подсетей
        if [[ "$interface" == "ens36" ]]; then
            IPV4_ADDRESS="22.22.22.100/24"
            IPV6_ADDRESS="2220:B::100/64"
        elif [[ "$interface" == "ens37" ]]; then
            IPV4_ADDRESS="172.16.0.33/28"
            IPV6_ADDRESS="172:16:E::1/124"
        else
            echo "Unsupported network interface: $interface"
            exit 1
        fi

        # Получаем текущий IPv4 и IPv6 адреса сетевого интерфейса
        CURRENT_IPV4=$(nmcli -g IP4.ADDRESS dev show "$interface")
        CURRENT_IPV6=$(nmcli -g IP6.ADDRESS dev show "$interface")

        # Проверяем, был ли изменен IPv4 или IPv6 адрес
        if [ "$CURRENT_IPV4" != "$IPV4_ADDRESS" ] || [ "$CURRENT_IPV6" != "$IPV6_ADDRESS" ]; then
            echo "IP addresses have been changed or connection does not exist. Removing old connection..."
            nmcli con delete "$interface"
        elif [ "$CURRENT_IPV4" = "$IPV4_ADDRESS" ] && [ "$CURRENT_IPV6" = "$IPV6_ADDRESS" ]; then
            echo "IP addresses are already assigned and have not changed. Skipping..."
            exit 0
        fi

        # Создаем новое соединение для интерфейса с указанием DNS-серверов
        nmcli con add con-name "$interface" ifname "$interface" type ethernet ip4 "$IPV4_ADDRESS" ip6 "$IPV6_ADDRESS" gw4 "$GATEWAY" ipv4.dns "${DNS_SERVERS[0]}" ipv6.dns "${DNS_SERVERS[1]}"

        # Активируем соединение
        nmcli con up "$interface"

        # Устанавливаем флаг, что интерфейс был найден и настроен
        interface_found=1
    fi
done

# Проверяем, был ли найден и настроен какой-либо интерфейс
if [ $interface_found -eq 0 ]; then
    echo "No active network interfaces found."
    exit 1
fi

# Добавляем маршруты IPv4 и IPv6
ip route add 0.0.0.0/0 via 22.22.22.1 proto static metric 100
ip -6 route add ::/0 via 2220:B::1 proto static metric 100

# Устанавливаем IP forwarding для IPv4 и IPv6
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
