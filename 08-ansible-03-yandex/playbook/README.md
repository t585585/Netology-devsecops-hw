## Установка `clickhouse` и `vector` и `lighthouse`

Данный playbook устанавливает `clichouse` и `vector` и `lighthouse` на соответствующие заранее подготовленные хосты, запускает службу `clichouse-server` и `vector`, а также создает базу `logs` в `clichouse`, устанавливает `nginx` и запускает его. 

В каталоге `group_vars` задаются необходимые версии дистрибутивов.

Для работы playbook необходимо:
 - подготовить хосты, прописать в `prod.yml` IP адреса хостов
 - запустить `ansible-playbook`:
```shell
ansible-playbook -i inventory/prod.yml site.yml
```