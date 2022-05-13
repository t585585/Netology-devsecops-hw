# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

## Ответ

```shell
docker pull postgres:13
docker volume create volume_pgs
docker run --rm --name d_pgs -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v volume_pgs:/var/lib/postgresql/data postgres:13
docker exec -it d_pgs psql -U postgres
```

**Найдите и приведите** управляющие команды для:
- вывода списка БД - `\l`
- подключения к БД - `\c [dbname]`
- вывода списка таблиц - `\dt`
- вывода описания содержимого таблиц -`\d NAME`
- выхода из psql - `\q`

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

## Ответ

```shell
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
```
```shell
root@85cc5cd4ed92:/# psql -U postgres -d test_database < /var/lib/postgresql/data/backup/test_dump.sql
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
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
```
```shell
docker exec -it d_pgs psql -U postgres
postgres=# \c test_database
test_database=# ANALYZE VERBOSE public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```
```shell
test_database=# select avg_width, attname FROM pg_stats WHERE tablename = 'orders' ORDER by attname DESC LIMIT 1;
 avg_width | attname
-----------+---------
        16 | title
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

## Ответ

- Преобразуем существующую таблицу в партиционированную - пересоздадим таблицу:
```shell
test_database=# alter table orders rename to orders_simple;
ALTER TABLE
test_database=# create table orders (id integer, title varchar(80), price integer) partition by range(price);
CREATE TABLE
test_database=# create table orders_1 partition of orders for values from (500) to (2147483647);
CREATE TABLE
test_database=# create table orders_2 partition of orders for values from (0) to (499);
CREATE TABLE
```
- Что получилось:
```shell
test_database=# \d+ orders
                                    Partitioned table "public.orders"
 Column |         Type          | Collation | Nullable | Default | Storage  | Stats target | Description
--------+-----------------------+-----------+----------+---------+----------+--------------+-------------
 id     | integer               |           |          |         | plain    |              |
 title  | character varying(80) |           |          |         | extended |              |
 price  | integer               |           |          |         | plain    |              |
Partition key: RANGE (price)
Partitions: orders_1 FOR VALUES FROM (500) TO (2147483647),
            orders_2 FOR VALUES FROM (0) TO (500)
```
- Наполним таблицу:
```shell
test_database=# insert into orders (id, title, price) select * from orders_old;
INSERT 0 8
```
- Содержимое таблиц:
  - orders
```shell
test_database=# SELECT * FROM orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)
```
  - orders_1
```shell
test_database=# SELECT * FROM orders_1;
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)
```
  - orders_2
```shell
test_database=# SELECT * FROM orders_2;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)
```

При изначальном проектировании таблиц можно было сделать её партиционированной, тогда не пришлось бы переименовывать исходную таблицу и переносить данные в новую.
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

## Ответ
- Создадим бэкап таблиц базы 
```shell
root@85cc5cd4ed92:/# pg_dump -U postgres -d test_database > /var/lib/postgresql/data/backup/test_database_postgres_13_dump.sql
```
- Для уникальности значения столбца `title` добавим строку в бэкап

```
ALTER TABLE ONLY public.orders ADD CONSTRAINT title_unique UNIQUE (title);
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
