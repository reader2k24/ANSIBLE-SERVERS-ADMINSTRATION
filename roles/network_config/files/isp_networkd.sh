#!/bin/bash

# Устанавливаем IPv4 и IPv6 адреса и их маски подсетей для каждого интерфейса
declare -A interface_addresses=(
    ["ens36"]="11.11.11.1/24|1110:A::1/64"
    ["ens37"]="22.22.22.1/24|2220:B::1/64"
    ["ens38"]="10.100.10.1/24|10:100:C::1/64"
)

# Переменная, показывающая, был ли найден активный интерфейс
interface_found=0

# Проходим по каждому интерфейсу и устанавливаем IP-адреса
for interface in "${!interface_addresses[@]}"; do
    # Получаем текущий статус интерфейса
    state=$(cat /sys/class/net/"$interface"/operstate)
    
    # Проверяем, активен ли интерфейс
    if [[ "$state" == "up" ]]; then
        # Получаем IPv4 и IPv6 адреса и их маски подсетей для текущего интерфейса
        IFS='|' read -r IPV4_ADDRESS IPV6_ADDRESS <<<"${interface_addresses[$interface]}"
        
        # Получаем текущий IPv4 и IPv6 адреса сетевого интерфейса
        CURRENT_IPV4=$(nmcli -g IP4.ADDRESS dev show "$interface")
        CURRENT_IPV6=$(nmcli -g IP6.ADDRESS dev show "$interface")

        # Проверяем, был ли изменен IPv4 или IPv6 адрес
        if [[ "$CURRENT_IPV4" != "$IPV4_ADDRESS" ]] || [[ "$CURRENT_IPV6" != "$IPV6_ADDRESS" ]]; then
            echo "IP addresses have been changed or connection does not exist. Removing old connection..."
            nmcli con delete "$interface"
        elif [[ "$CURRENT_IPV4" = "$IPV4_ADDRESS" ]] && [[ "$CURRENT_IPV6" = "$IPV6_ADDRESS" ]]; then
            echo "IP addresses are already assigned and have not changed. Skipping..."
            continue
        fi

        # Создаем новое соединение для интерфейса
        nmcli con add con-name "$interface" ifname "$interface" type ethernet ip4 "$IPV4_ADDRESS" ip6 "$IPV6_ADDRESS" gw4 "$GATEWAY"

        # Активируем соединение
        nmcli con up "$interface"

        # Устанавливаем флаг, что интерфейс был найден и настроен
        interface_found=1
    fi
done

# Проверяем, был ли найден и настроен какой-либо интерфейс
if [[ $interface_found -eq 0 ]]; then
    echo "No active network interfaces found."
    exit 1
fi

# Устанавливаем IP forwarding для IPv4 и IPv6
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
