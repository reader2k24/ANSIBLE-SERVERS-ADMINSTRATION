#!/bin/bash

backup_files="/home /etc"
dest="/opt/backup"

day=$(date +%A-%F)
hostname=$(hostname -s)
archive_file="$hostname-$day.tgz"

# Создание каталога, если он не существует
mkdir -p "$dest"

tar czf "$dest/$archive_file" $backup_files
