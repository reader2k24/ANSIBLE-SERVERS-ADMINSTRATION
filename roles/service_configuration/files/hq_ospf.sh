#!/bin/bash

# Установка переменных для конфигурации OSPF
INTERFACE1="ens37"
INTERFACE2="gre1"
NETWORK1="131.131.0.0/26"
NETWORK2="172.28.14.0/24"
ROUTER_ID="11.11.11.100"

# Проверка наличия FRR
if ! command -v vtysh > /dev/null 2>&1; then
    echo "Не найден vtysh. Убедитесь, что FRRouting установлен."
    exit 1
fi

# Настройка OSPF с использованием vtysh
{
    echo "conf t"
    echo "hostname HQ-R"
    echo "log syslog informational"
    echo "service integrated-vtysh-config"
    echo "interface $INTERFACE1"
    echo "ipv6 ospf6 area 0"
    echo "exit"
    echo "interface $INTERFACE2"
    echo "ipv6 ospf6 area 0"
    echo "exit"
    echo "router ospf"
    echo "network $NETWORK1 area 0"
    echo "network $NETWORK2 area 0"
    echo "exit"
    echo "router ospf6"
    echo "ospf6 router-id $ROUTER_ID"
    echo "exit"
    echo "do write"
    echo "exit"
    echo "copy running-config startup-config" # Сохранение конфигурации
} | vtysh

echo "Настройка OSPF завершена."
