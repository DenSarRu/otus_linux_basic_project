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
echo "Устанавливаем Filebeat"
echo "============================================================"

apt install default-jdk -y

dpkg -i /home/dds/distrib/filebeat_8.17.1_amd64-224190-a5f894.deb

echo "Укажите IP адрес сервера мониторинга"
read monitor_ip

sed -i '16i\- type: filestream\n  paths:\n    - \/var\/log\/nginx\/*.log\n\n  enabled: true\n  exclude_files: \[".gz$"]\n  prospector.scanner.exclude_files: \[".gz$"]' /etc/filebeat/filebeat.yml
sed -i "s/output.elasticsearch/#output.elasticsearch/" /etc/filebeat/filebeat.yml
sed -i 's/hosts: \[\"localhost:9200\"\]/#hosts: \[\"localhost:9200\"\]/' /etc/filebeat/filebeat.yml
sed -i 's/preset: balanced/#preset: balanced/' /etc/filebeat/filebeat.yml
sed -i "s/#output.logstash:/output.logstash:\n  hosts: ['${monitor_ip}:5400']/" /etc/filebeat/filebeat.yml

systemctl restart filebeat

echo "============================================================"
echo "Теперь нужно настроить сервер DB-SLAVE... "
echo "Переходи на ВМ №2. И запусти на нем 05_install-database_slave.sh"
echo "============================================================"
