#!/bin/bash
#============================================================
# Установка и настройка prometheus и node exporter
#============================================================

if [ "$EUID" -ne 0 ]
then
    echo "Нужны повышенные привелегии, используйте sudo"
    exit
fi

echo "============================================================"
echo "Устанавливаем prometheus"
echo "============================================================"

apt install prometheus -y

echo "============================================================"
echo "Добавляем адреса серверов в конфигурацию prometheus"
echo "============================================================"

echo "Укажите IP адрес сервера DB-MASTER"
read master_ip
echo "Укажите IP адрес сервера DB-SLAVE"
read slave_ip

newip="'localhost:9100','$master_ip:9100','$slave_ip:9100'"
sed -i "s/'localhost:9100'/$newip/g" /etc/prometheus/prometheus.yml

service prometheus restart

echo "============================================================"
echo "Устанавливаем node-exporter на наши сервера"
echo "============================================================"

echo "Укажите пользователя под которым будем подключаться к серверам:"
read user_name

ssh -t "user_name"@"$master_ip" "sudo apt install prometheus-node-exporter -y"
ssh -t "user_name"@"$slave_ip" "sudo apt install prometheus-node-exporter -y"

echo "============================================================"
echo "Устанавливаем и запускаем Grafana"
echo "============================================================"

apt install -y adduser libfontconfig1 musl
dpkg -i /home/"$user_name"/distrib/grafana_12.3.3_21957728731_linux_amd64-224190-b33d09.deb

# Запуск
systemctl daemon-reload
systemctl enable --now grafana-server
