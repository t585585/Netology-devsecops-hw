# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Ответ:

- Dockerfile:
```shell
FROM centos:7

ENV PATH=/usr/lib:/usr/lib/jvm/jre-11/bin:$PATH JAVA_HOME=/opt/elasticsearch-8.0.1/jdk/ ES_HOME=/opt/elasticsearch-8.0.1

RUN yum install wget -y \
    && yum install perl-Digest-SHA -y \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 \
    && shasum -a 512 -c elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 \ 
    && tar -C /opt -xzf elasticsearch-8.0.1-linux-x86_64.tar.gz \
    && rm elasticsearch-8.0.1-linux-x86_64.tar.gz\
    && rm elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 \
    && groupadd elasticsearch \
    && useradd -g elasticsearch elasticsearch \
    && mkdir /var/lib/elasticsearch \
    && mkdir /var/log/elasticsearch \
    && mkdir /opt/elasticsearch-8.0.1/snapshots \
    && chown elasticsearch:elasticsearch /var/lib/elasticsearch \
    && chown elasticsearch:elasticsearch /var/log/elasticsearch \
    && chown -R elasticsearch:elasticsearch /opt/elasticsearch-8.0.1/
    
ADD elasticsearch.yml /opt/elasticsearch-8.0.1/config/
    
USER elasticsearch
CMD ["/usr/sbin/init"]
CMD ["/opt/elasticsearch-8.0.1/bin/elasticsearch"]
```
- Ссылка на образ:\
```shell
vagrant@vagrant:~/hw65$ docker build . -t t585585/elasticsearch:8.0.1
vagrant@vagrant:~/hw65$ docker login -u "t585585"
vagrant@vagrant:~/hw65$ docker push t585585/elasticsearch:8.0.1
```
[t585585/elasticsearch:8.0.1](https://hub.docker.com/repository/docker/t585585/elasticsearch)
- Ответ на запрос:
```shell
vagrant@vagrant:~/hw65$ docker run --rm -d --name d_elastic -p 9200:9200 -p 9300:9300 t585585/elasticsearch:8.0.1
```
```shell
vagrant@vagrant:~/hw65$ curl -X GET 'localhost:9200/'
```
```json
{
  "name" : "cc5048e0fe6f",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "z9oVJIzwSrehumQXjgHOIA",
  "version" : {
    "number" : "8.0.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "801d9ccc7c2ee0f2cb121bbe22ab5af77a902372",
    "build_date" : "2022-02-24T13:55:40.601285296Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Ответ
- Создаем индексы с заданными параметрами
```shell
curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'
```
- Получаем список индексов
```shell
vagrant@vagrant:~/hw65$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 0caEwlPrQ1uYMCBcq-5kNA   1   0          0            0       225b           225b
yellow open   ind-3 uleHbH_rSvWeNXdwVBfBug   4   2          0            0       900b           900b
yellow open   ind-2 -UeNvEdBSFuLgk69YAXLoA   2   1          0            0       450b           450b
```
- Статус индексов
```shell
vagrant@vagrant:~/hw65$ curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
vagrant@vagrant:~/hw65$ curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
vagrant@vagrant:~/hw65$ curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```
- Состояние кластера
```shell
vagrant@vagrant:~/hw65$ curl -X GET 'localhost:9200/_cluster/health?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```


Часть индексов и кластер находится в состоянии yellow, т.к. у них должны быть реплики, но в кластере всего одна нода, поэтому размещать их негде. В таком случае кластер помечает их желтыми.

- Удаляем все индексы
```shell
vagrant@vagrant:~/hw65$ curl -X DELETE 'http://localhost:9200/_all'
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

## Ответ
- Регистрируем папку `snapshots`
```shell
vagrant@vagrant:~/hw65$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d '{"type": "fs","settings": {"location": "/opt/elasticsearch-8.0.1/snapshots/"}}'
{
  "acknowledged" : true
}
```
- Результат регистрации папки `snapshots`
```shell
vagrant@vagrant:~/hw65$ curl -X GET 'localhost:9200/_snapshot/netology_backup?pretty'
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/opt/elasticsearch-8.0.1/snapshots/"
    }
  }
}
```
- Создаем индекс `test` с заданными параметрами
```shell
vagrant@vagrant:~/hw65$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d '{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}
```
- Список индексов
```shell
vagrant@vagrant:~/hw65$ curl -X GET 'localhost:9200/_cat/indices'
green open test TfsIslnsTRW92uSk0L3fxA 1 0 0 0 225b 225b
```
- Создаем `snapshot` состояния сервера 
```shell
vagrant@vagrant:~/hw65$ curl -X PUT "localhost:9200/_snapshot/netology_backup/test_snapshot?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "test_snapshot",
    "uuid" : "FF_brRQ9QvOc09kugeH49w",
    "repository" : "netology_backup",
    "version_id" : 8000199,
    "version" : "8.0.1",
    "indices" : [
      "test",
      ".geoip_databases"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-05-19T19:19:06.613Z",
    "start_time_in_millis" : 1652987946613,
    "end_time" : "2022-05-19T19:19:08.423Z",
    "end_time_in_millis" : 1652987948423,
    "duration_in_millis" : 1810,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```
- Cписок файлов в директории со `snapshot`ами
```shell
[elasticsearch@cc5048e0fe6f /]$ ls -lh /opt/elasticsearch-8.0.1/snapshots/
total 36K
-rw-r--r-- 1 elasticsearch elasticsearch  846 May 19 19:19 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 May 19 19:19 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch 4.0K May 19 19:19 indices
-rw-r--r-- 1 elasticsearch elasticsearch  18K May 19 19:19 meta-FF_brRQ9QvOc09kugeH49w.dat
-rw-r--r-- 1 elasticsearch elasticsearch  351 May 19 19:19 snap-FF_brRQ9QvOc09kugeH49w.dat
```
- Удаляем индекс `test` и создаем индекс `test-2`
```shell
[elasticsearch@cc5048e0fe6f /]$ curl -X DELETE "localhost:9200/test"
{"acknowledged":true}
[elasticsearch@cc5048e0fe6f /]$ curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
```
- Список индексов
```shell
[elasticsearch@cc5048e0fe6f /]$ curl -X GET 'localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 JXu3R5byRKKp5xbzq3QC0Q   1   0          0            0       225b           225b
```
- Восстанавливаем состояние сервера из `snapshot`а
```shell
[elasticsearch@cc5048e0fe6f /]$ curl -X POST "localhost:9200/_snapshot/netology_backup/test_snapshot/_restore?pretty"
{
  "accepted" : true
}
```
- Итоговый список индексов
```shell
[elasticsearch@cc5048e0fe6f /]$ curl -X GET 'localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 JXu3R5byRKKp5xbzq3QC0Q   1   0          0            0       225b           225b
green  open   test   pfSF2hAnRnymRCXFt-_3tQ   1   0          0            0       225b           225b
```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
