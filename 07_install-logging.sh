#!/bin/bash
#============================================================
# Установка и настройка стека ELK
#============================================================

if [ "$EUID" -ne 0 ]
then
    echo "Нужны повышенные привелегии, используйте sudo"
    exit
fi

echo "============================================================"
echo "Устанавливаем Elasticsearch"
echo "============================================================"

apt install default-jdk -y

dpkg -i /home/dds/distrib/elasticsearch_8.17.1_amd64-224190-db972d.deb

echo "============================================================"
echo "Отключаем проверку сертификатов"
echo "============================================================"

sed -i "s/true/false/" /etc/elasticsearch/elasticsearch.yml

echo "============================================================"
echo "Запускаем Elasticsearch"
echo "============================================================"

systemctl daemon-reload
systemctl enable --now elasticsearch.service

echo "============================================================"
echo "Устанавливаем Kibana"
echo "============================================================"
 
dpkg -i /home/dds/distrib/kibana_8.17.1_amd64-224190-42bf22.deb

echo "============================================================"
echo "Изменим кофигурационный файл и запускаем Kibana"
echo "============================================================"

sed -i "s/#server.port/server.port/" /etc/kibana/kibana.yml
sed -i "s/#server.host: \"localhost\"/server.host: \"0.0.0.0\"/" /etc/kibana/kibana.yml

systemctl daemon-reload
systemctl enable --now kibana.service

echo "============================================================"
echo "Устанавливаем Logstash"
echo "============================================================"

dpkg -i /home/dds/distrib/logstash_8.17.1_amd64-224190-40c12c.deb

systemctl enable --now logstash.service

echo "============================================================"
echo "Настраиваем Logstash"
echo "============================================================"

sed -i "s/# path.config:/path.config: \/etc\/logstash\/conf.d/" /etc/logstash/logstash.yml
cp ./config/logstash-nginx-es.conf /etc/logstash/conf.d/logstash-nginx-es.conf

systemctl restart logstash.service

