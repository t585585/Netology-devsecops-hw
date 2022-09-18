## Установка `clickhouse` и `vector` и `lighthouse` с использованием ролей

Данный playbook устанавливает `clichouse` и `vector` и `lighthouse` на соответствующие контейнеры `CentOS7` поднятые при помощи `docker-compose` при помощи ролей, запускает службу `clichouse-server` и `vector`, а также создает базу `logs` в `clichouse`, устанавливает `nginx` и запускает его. 

В каталоге `group_vars` задаются необходимые версии дистрибутивов.

Для работы playbook необходимо:
 - запустить `docker-compose`
```shell
docker-compose up
```
 - запустить `ansible-playbook`:
```shell
ansible-playbook -i inventory/prod.yml site.yml
```

