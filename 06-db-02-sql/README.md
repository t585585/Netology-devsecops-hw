# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

## Ответ:
````shell
vagrant@vagrant:~/hw62$ docker pull postgres:12
...
vagrant@vagrant:~/hw62$ docker volume create volume1
volume1
vagrant@vagrant:~/hw62$ docker volume create volume2
volume2
vagrant@vagrant:~/hw62$ docker run --rm --name pg -e POSTGRES_PASSWORD=postgres -it -p 5432:5432 -v volume1:/var/lib/postgresql/data -v volume2:/var/lib/postgresql/backup postgres:12 bash
````

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

## Ответ:
- итоговый список БД после выполнения пунктов выше,
````shell
test_db-# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)
````
- описание таблиц (describe)
```shell
test_db-# \d clients
                                         Table "public.clients"
      Column       |       Type        | Collation | Nullable |                 Default
-------------------+-------------------+-----------+----------+------------------------------------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying |           | not null |
 страна проживания | character varying |           | not null |
 Заказ             | integer           |           | not null | nextval('"clients_Заказ_seq"'::regclass)
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "страна проживания" btree ("страна проживания")
Foreign-key constraints:
    "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)
```
```shell
test_db-# \d orders
                                    Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default
--------------+-------------------+-----------+----------+------------------------------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying |           | not null |
 цена         | integer           |           | not null |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)
```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```shell
test_db=# SELECT DISTINCT grantee,table_catalog,table_name FROM information_schema.table_privileges WHERE table_catalog IN ('test_db') AND table_name IN ('clients','orders') ORDER BY table_name;
     grantee      | table_catalog | table_name
------------------+---------------+------------
 postgres         | test_db       | clients
 test-admin-user  | test_db       | clients
 test-simple-user | test_db       | clients
 postgres         | test_db       | orders
 test-admin-user  | test_db       | orders
 test-simple-user | test_db       | orders
(6 rows)
```
- список пользователей с правами над таблицами test_db
```shell
test_db=# \dp
                                             Access privileges
 Schema |       Name        |   Type   |         Access privileges          | Column privileges | Policies
--------+-------------------+----------+------------------------------------+-------------------+----------
 public | clients           | table    | postgres=arwdDxt/postgres         +|                   |
        |                   |          | "test-admin-user"=arwdDxt/postgres+|                   |
        |                   |          | "test-simple-user"=arwd/postgres   |                   |
 public | clients_id_seq    | sequence |                                    |                   |
 public | clients_Заказ_seq | sequence |                                    |                   |
 public | orders            | table    | postgres=arwdDxt/postgres         +|                   |
        |                   |          | "test-admin-user"=arwdDxt/postgres+|                   |
        |                   |          | "test-simple-user"=arwd/postgres   |                   |
 public | orders_id_seq     | sequence |                                    |                   |
(5 rows)
```
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

## Ответ:

- наполняем таблицы БД
```shell
test_db=# INSERT INTO orders (наименование, цена) VALUES ('Шоколад', 10), ('Принтер', 3000), ('Книга', 500), ('Монитор', 7000), ('Гитара', 4000);
SELECT * FROM orders;
INSERT 0 5
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)
```
```shell
test_db=# INSERT INTO clients (фамилия, "страна проживания") VALUES ('Иванов Иван Иванович', 'USA'), ('Петров Петр Петрович', 'Canada'), ('Иоганн Себастьян Бах', 'Japan'), ('Ронни Джеймс Дио', 'Russia'), ('Ritchie Blackmore', 'Russia');
SELECT * FROM clients;
INSERT 0 5
 id |       фамилия        | страна проживания | Заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     1
  2 | Петров Петр Петрович | Canada            |     2
  3 | Иоганн Себастьян Бах | Japan             |     3
  4 | Ронни Джеймс Дио     | Russia            |     4
  5 | Ritchie Blackmore    | Russia            |     5
(5 rows)
```

- вычисляем количество записей в таблицах БД
```shell
test_db=# SELECT count(*) FROM clients;
 count
-------
     5
(1 row)

test_db=# SELECT count(*) FROM orders;
 count
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказка - используйте директиву `UPDATE`.

## Ответ:
```shell
test_db=# UPDATE clients SET Заказ=id+2 WHERE id<4;
UPDATE 3
```

```shell
test_db=# SELECT c.фамилия AS ФИО, o.наименование AS Заказ FROM clients c, orders o WHERE c.Заказ = o.id AND c.id < 4;
         ФИО          |  Заказ
----------------------+---------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Ответ:

```shell
test_db=# VACUUM ANALYZE;
VACUUM
test_db=# EXPLAIN ANALYZE SELECT c.фамилия AS ФИО, o.наименование AS Заказ FROM clients c, orders o WHERE c.Заказ = o.id AND c.id < 4;
                                                   QUERY PLAN
----------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=1.10..2.21 rows=3 width=46) (actual time=0.017..0.020 rows=3 loops=1)
   Hash Cond: (o.id = c."Заказ")
   ->  Seq Scan on orders o  (cost=0.00..1.05 rows=5 width=17) (actual time=0.004..0.005 rows=5 loops=1)
   ->  Hash  (cost=1.06..1.06 rows=3 width=37) (actual time=0.008..0.008 rows=3 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Seq Scan on clients c  (cost=0.00..1.06 rows=3 width=37) (actual time=0.004..0.005 rows=3 loops=1)
               Filter: (id < 4)
               Rows Removed by Filter: 2
 Planning Time: 0.203 ms
 Execution Time: 0.034 ms
(10 rows)
```

Данная команда отображает какой план выбрала СУБД для обработки запроса. В данном случае СУБД выбрала соединение по хешу - `Hash Join`, при котором строки одной таблицы записываются в хеш-таблицу в памяти, после чего сканируется другая таблица и для каждой её строки проверяется соответствие по хеш-таблице.\
\
Директива `EXPLAIN` является очень мощным инструментом для анализа запросов. Понимание плана — это _искусство_, и чтобы овладеть им, нужен определённый опыт.

Значение в скобках:
- `cost` - приблизительная стоимость запуска (получение первой строки) и приблизительная общая стоимость (получение всех строк);
- `rows` - Ожидаемое число строк, которое должен вывести этот узел плана;
- `width` - Ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).


## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

## Ответ:
- Бэкапим БД
```shell
pg_dump test_db -f /var/lib/postgresql/backup/dump_test_db.sql
```
- запускаем новый контейнер и подключаем volume с бэкапом
```shell
vagrant@vagrant:~/hw62$ docker run --rm --name pg_2 -e POSTGRES_PASSWORD=postgres -it -p 5432:5432 -v volume2:/var/lib/postgresql/backup postgres:12 bash
```
- восстанавливаем БД из бэкапа
```shell
postgres-# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```
```shell
postgres=# create database test_db;
CREATE DATABASE
postgres=# \q
postgres@cc743545be6d:/$ psql -d test_db -f /var/lib/postgresql/backup/dump_test_db.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
      5
(1 row)

 setval
--------
      5
(1 row)

 setval
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
GRANT
GRANT
GRANT
```
---

### Как сдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---