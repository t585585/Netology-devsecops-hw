# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Ответ

- Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
```shell
docker pull mysql:8.0
docker volume create volume_mysql
docker run --rm --name d_mysql -e MYSQL_ROOT_PASSWORD=mysql -d -p 3306:3306 -v volume_mysql:/etc/mysql/ mysql:8.0
docker cp test_dump.sql d_mysql:/etc/mysql/backup/test_dump.sql
docker exec -it d_mysql bash 
```
- Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```shell
mysql -uroot -pmysql
mysql> status
--------------
mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          18
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.29 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 41 min 46 sec

Threads: 3  Questions: 87  Slow queries: 0  Opens: 184  Flush tables: 3  Open tables: 101  Queries per second avg: 0.034
--------------
```
- Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```shell
mysql -uroot -pmysql -e 'create database test_db;' && mysql -uroot -pmysql test_db < /etc/mysql/backup/test_dump.sql && mysql -uroot -pmysql -e 'use test_db; show tables;'

+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
```
- **Приведите в ответе** количество записей с `price` > 300.
```shell
mysql> use test_db;
mysql> SELECT * FROM orders WHERE price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

## Ответ

```shell
mysql> CREATE USER 'test'@'localhost'
    -> IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> WITH MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"fname": "Pretty", "lname": "James"}';
Query OK, 0 rows affected (0.01 sec)
```
```shell
mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.01 sec)
```
```shell
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "Pretty", "lname": "James"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

## Ответ
- Установите профилирование `SET profiling = 1`.
- Изучите вывод профилирования команд `SHOW PROFILES;`.
```shell
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.01 sec)

mysql> SHOW PROFILES;
+----------+------------+-------------------+
| Query_ID | Duration   | Query             |
+----------+------------+-------------------+
|        1 | 0.00015575 | SET profiling = 1 |
|        2 | 0.00389050 | FLUSH PRIVILEGES  |
+----------+------------+-------------------+
2 rows in set, 1 warning (0.00 sec)
```
- Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
```shell
mysql> SHOW TABLE STATUS FROM test_db;
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| Name   | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time         | Check_time | Collation          | Checksum | Create_options | Comment |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| orders | InnoDB |      10 | Dynamic    |    5 |           3276 |       16384 |               0 |            0 |         0 |              6 | 2022-05-12 19:23:34 | 2022-05-12 19:23:34 | NULL       | utf8mb4_0900_ai_ci |     NULL |                |         |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
1 row in set (0.01 sec)
```
- Измените engine и приведите время выполнения и запрос на изменения из профайлера в ответе:
  - на `MyISAM`
  - на `InnoDB`
```shell
mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.05 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+------------------------------------+
| Query_ID | Duration   | Query                              |
+----------+------------+------------------------------------+
|        1 | 0.04721325 | ALTER TABLE orders ENGINE = MyISAM |
|        2 | 0.03605825 | ALTER TABLE orders ENGINE = InnoDB |
+----------+------------+------------------------------------+
5 rows in set, 1 warning (0.00 sec)
```
Продолжительность переключения на `MyISAM`: 0.04721325\
Продолжительность переключения на `InnoDB`: 0.03605825

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

## Ответ

```shell
root@d3ed3305c8e9:/# cat /etc/mysql/my.cnf

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

innodb_flush_log_at_trx_commit  = 2
innodb_file_format              = Barracuda
innodb_log_buffer_size          = 1M
key_buffer_size                 = 614M
innodb_log_file_size            = 100M
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
