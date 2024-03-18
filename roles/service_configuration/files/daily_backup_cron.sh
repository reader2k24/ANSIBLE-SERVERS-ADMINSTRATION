#!/bin/bash

# Путь к вашему скрипту резервного копирования
backup_script="/usr/local/sbin/backup.sh"

# Проверяем, существует ли уже задача в crontab
if ! crontab -l | grep -q "$backup_script"; then
    # Если задачи еще нет, добавляем ее
    (crontab -l ; echo "0 3 * * * $backup_script") | crontab -
fi
