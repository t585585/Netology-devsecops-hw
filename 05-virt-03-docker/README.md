# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

Сценарий выполнения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

## Ответ:

Ссылка на репозиторий: https://hub.docker.com/repository/docker/t585585/nginx

````shell
docker run -d -p 80:80 t585585/nginx:v1
````

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

## Ответ:

Не имею опыта работы с данными системами, но думаю, что нужно использовать гибридное решение. Для высоконагруженных систем использовать аппаратную виртуализацию, либо физические сервера. Для более простых задач использовать контейнеры Docker. А можно для всего использовать контейнеры Docker и посмотреть как будет работать. Получить опыт и принять взвешенное решение об изменении инфраструктуры. 

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

## Ответ:

````
docker run -it -d -v /data:/data --name centos centos
docker run -it -d -v /data:/data --name debian debian
````
````
docker exec -it centos bash
[root@21341b64c219 /]# echo > /data/file_centos.txt
[root@21341b64c219 /]# exit
````
````
vagrant@vagrant:~$ sudo touch /data/file_host.txt
````
````
vagrant@vagrant:~$ docker exec -it debian bash
root@c978c597bee4:/# ls /data/
file_centos.txt  file_host.txt
root@c978c597bee4:/# exit
````

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

## Ответ:

Ссылка на репозиторий: https://hub.docker.com/repository/docker/t585585/ansible

````
vagrant@vagrant:~/ansible$ docker build -t t585585/ansible:v1 .
````

````
vagrant@vagrant:~/ansible$ docker run -it 3999e1153a2d ansible-playbook --version
ansible-playbook [core 2.12.5]
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.9/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible-playbook
  python version = 3.9.5 (default, Nov 24 2021, 21:19:13) [GCC 10.3.1 20210424]
  jinja version = 3.1.2
  libyaml = False
````
