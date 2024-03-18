#!/bin/bash

# Указываем сетевой интерфейс, который нужно перезагрузить
NETWORK_INTERFACE="ens36"

# Пытаемся отключить сетевой интерфейс
nmcli dev disconnect "$NETWORK_INTERFACE"

# Подключаем сетевой интерфейс снова, независимо от статуса
nmcli dev connect "$NETWORK_INTERFACE"
