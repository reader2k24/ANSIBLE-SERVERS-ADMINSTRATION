#!/bin/bash

# Установка параметров VPN Tummel
LOCAL_IP=$(ip -o -4 addr show ens36 | awk '{print $4}' | cut -d'/' -f1)
REMOTE_IP="22.22.22.100"
TUNNEL_INTERFACE="gre1"
TUNNEL_LOCAL_IP="172.28.14.251/24"
TUNNEL_REMOTE_IP="172.28.14.252/24"
TUNNEL_IPV6_LOCAL="172:28:14::a/64"
TUNNEL_IPV6_REMOTE="172:28:14::b/64"
SPECIFIC_INTERFACE="ens36"

# Проверка существующего соединения с именем 'gre1'
existing_connection=$(nmcli connection show | grep "gre1")

# Если соединение существует, удаляем его
if [ -n "$existing_connection" ]; then
    echo "Существующее соединение 'gre1' найдено. Удаляем..."
    nmcli connection delete "gre1"
fi

# Создаем новое туннельное соединение
echo "Создаем новое соединение 'gre1' с привязкой к интерфейсу $SPECIFIC_INTERFACE..."
nmcli connection add type ip-tunnel ifname $TUNNEL_INTERFACE con-name $TUNNEL_INTERFACE mode gre local $LOCAL_IP remote $REMOTE_IP ip-tunnel.parent $SPECIFIC_INTERFACE

# Устанавливаем IPv4 и IPv6 адреса для туннельного соединения
nmcli connection modify $TUNNEL_INTERFACE ipv4.addresses $TUNNEL_LOCAL_IP
nmcli connection modify $TUNNEL_INTERFACE ipv6.addresses $TUNNEL_IPV6_LOCAL

# Перезагружаем NetworkManager
systemctl restart NetworkManager
