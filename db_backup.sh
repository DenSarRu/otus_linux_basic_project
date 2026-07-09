#!/bin/bash

MYSQL='mysql --skip-column-names'

# укажем имя обрабатываемой базы данных
db_name="employees"

echo "Обрабатываем БД: "$db_name;

# для базы данных создаем свой каталог

current_date=$(date +"%Y-%m-%d")
backup_path=$current_date"-"$db_name;
echo "Создаем каталог /var/db-backup/$backup_path"

mkdir -p "/var/db-backup/"$backup_path;

# добавить проверку и УДАЛЕНИЕ старых бэкапов

# получаем список таблиц БД
echo "получаем список таблиц БД"
db_tables=`$MYSQL -e "SHOW TABLES FROM "$db_name`;

for table in $db_tables;
  do
    echo "обрабатываем таблицу $table"
    dump_name="/var/db-backup/"$backup_path"/"$table".sql";
    /usr/bin/mysqldump $db_name $table --add-locks --create-options --disable-keys --extended-insert --skip-lock-tables --single-transaction  --set-gtid-purged=OFF --quick --set-charset --events --routines --triggers > $dump_name;
done

echo "--------------------------------------------------";
echo "Получен бэкап БД: "$db_name;
echo "--------------------------------------------------";