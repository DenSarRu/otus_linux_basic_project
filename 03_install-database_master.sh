#!/bin/bash

#============================================================
# Установка MySql и настройка репликации на сервере DB-MASTER
#============================================================

if [ "$EUID" -ne 0 ]
then
    echo "Нужны повышенные привелегии! Используй sudo"
    exit
fi

# Устанавливаем MySQL
echo "============================================================"
echo "Установка MySql на сервере DB-MASTER"
echo "============================================================"

apt install mysql-server-8.0 -y

systemctl enable mysql
systemctl start mysql

echo "============================================================"
echo "Настраиваем сервер DB-MASTER"
echo "============================================================"
sleep 3
echo "Копируем конфигурацию и перезагружаем MySQL"
sleep 3
cp ./config/mysqld_master.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

echo "============================================================"
echo "Создаём пользователя для реплики"
echo "============================================================"

mysql -e "CREATE USER repl@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'P@ssw0rd';"
echo "Даём ему права на репликацию"
mysql -e "GRANT REPLICATION SLAVE ON *.* TO repl@'%';"

echo "============================================================"
echo "Разворачиваем базу данных из бэкапа"
echo "============================================================"
cd ./statics/emp
mysql < employees.sql

echo "============================================================"
echo "Устанавливаем пароль для пользователя root"
echo "============================================================"
echo "Укажите пароль пользователя root для работы с mysql :"
read -s root_pass
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'caching_sha2_password' BY '$root_pass';"

echo -e "[client]\nuser=root\npassword='$root_pass'" >> /root/.my.cnf

echo "============================================================"
echo "Теперь нужно настроить FileBeat для сбора логов с этого сервера..." 
echo "Запусти 04_install-filebeat.sh"
echo "============================================================"