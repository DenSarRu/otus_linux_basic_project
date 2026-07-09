#!/bin/bash

#============================================================
# Установка MySql и настройка репликации на сервере DB-SLAVE
#============================================================

if [ "$EUID" -ne 0 ]
then
    echo "Нужны повышенные привелегии! Используй sudo"
    exit
fi

# Устанавливаем MySQL
echo "============================================================"
echo "Установка MySql на сервере DB-SLAVE"
echo "============================================================"

apt install mysql-server-8.0 -y

systemctl enable mysql
systemctl start mysql

echo "============================================================"
echo "Настраиваем сервер DB-SLAVE"
echo "============================================================"
sleep 3
echo "Копируем конфигурацию и перезагружаем службу MySQL"
sleep 3
cp ./config/mysqld_slave.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

echo "============================================================"
echo "Укажите IP адрес сервера DB-MASTER:"
read master_ip
echo "============================================================"
echo "Настраиваем и запускаем репликацию"
mysql -e "STOP REPLICA;"
mysql -e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='$master_ip', SOURCE_USER='repl', SOURCE_PASSWORD='P@ssw0rd', SOURCE_AUTO_POSITION = 1, GET_SOURCE_PUBLIC_KEY = 1;"
mysql -e "START REPLICA;"
echo "============================================================"
echo "Проверяем состояние репликации"
mysql -e "show replica status\G"

echo "============================================================"
echo "Устанавливаем пароль для пользователя root"
echo "============================================================"
echo "Укажите пароль пользователя root для работы с mysql :"
read -s root_pass
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'caching_sha2_password' BY '$root_pass';"
echo -e "[client]\nuser=root\npassword='$root_pass'" >> /root/.my.cnf

echo "============================================================"
echo "создаем директорию для бэкапов /var/db-backup"
mkdir -p /var/db-backup
echo "============================================================"

echo "добавляем скрип для бэкапа БД в планировщик"
cp db_backup.sh /etc/cron.daily/db_backup
chmod ugo+x /etc/cron.daily/db_backup

echo "============================================================"
echo "Настройка сервера DB-SLAVE завершена. "
echo "Проверь работу скрипта для бэкапа БД. И переходи к настройке мониторинга и логирования"
echo "============================================================"