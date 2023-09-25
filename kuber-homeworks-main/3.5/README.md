# Домашнее задание к занятию Troubleshooting

### Цель задания

Устранить неисправности при деплое приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить

1. Установить приложение по команде:

```shell
kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```

2. Выявить проблему и описать.

3. Исправить проблему, описать, что сделано.

4. Продемонстрировать, что проблема решена.

### Решение

- Изучив содержимое манифеста, сразу виднно, что приложения будут деплоиться в неймспейсы отличные от default и это вызовет ошибку при выполнении команды, т.к. неймспейсов `web` и `data` в кластере пока нет. Поэтому предварительно создадим их кодмандами:

```shell
kubectl create namespace web
kubectl create namespace data
```

```text
namespace/web created
namespace/data created
```

- Также видно, что в приложении `web-consumer` выполняется команда `while true; do curl auth-db; sleep 5; done` и обращение идет по имени `auth-db` без указания неймспейса - будет ошибка. Проверим после деплоя приложений.

```shell
kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```

```text
deployment.apps/web-consumer created
deployment.apps/auth-db created
service/auth-db created
```

- проверим готовность подов

```shell
kubectl get pods -A
```

```text
NAMESPACE     NAME                               READY   STATUS    RESTARTS       AGE
data          auth-db-864ff9854c-6h2q7           1/1     Running   0              2m40s
kube-system   coredns-5d78c9869d-jxz2t           1/1     Running   1 (3h8m ago)   3h12m
kube-system   etcd-minikube                      1/1     Running   1 (3h8m ago)   3h12m
kube-system   kube-apiserver-minikube            1/1     Running   1 (3h8m ago)   3h12m
kube-system   kube-controller-manager-minikube   1/1     Running   1 (3h8m ago)   3h12m
kube-system   kube-proxy-k4xdc                   1/1     Running   1 (3h8m ago)   3h12m
kube-system   kube-scheduler-minikube            1/1     Running   1 (3h8m ago)   3h12m
kube-system   storage-provisioner                1/1     Running   4 (179m ago)   3h12m
web           web-consumer-84fc79d94d-9ws49      1/1     Running   0              2m40s
web           web-consumer-84fc79d94d-gs6qn      1/1     Running   0              2m40s
```

Поды запущены, ошибок не наблюдается.

- Посмотрим логи `web-consumer`

```shell
kubectl logs -n web web-consumer-84fc79d94d-9ws49
```

```text
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
```

Как и предпологалось ошибка с обнаружением хоста.

- Т.к. манифест расположен в репозитарии и редактировать мы его не можем, то отредактируем деплой локально (хотя, можно было бы скачать манифест к себе и отредактировать). Исправим команду, добавив к имени хоста имя неймспейса:

```yaml
       - while true; do curl auth-db.data; sleep 5; done
```

```shell
kubectl edit deployment web-consumer -n web
```

```text
deployment.apps/web-consumer edited
```

- Поды пересоздались

```text
NAMESPACE     NAME                               READY   STATUS        RESTARTS        AGE
data          auth-db-864ff9854c-6h2q7           1/1     Running       0               9m27s
kube-system   coredns-5d78c9869d-jxz2t           1/1     Running       1 (3h15m ago)   3h19m
kube-system   etcd-minikube                      1/1     Running       1 (3h15m ago)   3h19m
kube-system   kube-apiserver-minikube            1/1     Running       1 (3h15m ago)   3h19m
kube-system   kube-controller-manager-minikube   1/1     Running       1 (3h15m ago)   3h19m
kube-system   kube-proxy-k4xdc                   1/1     Running       1 (3h15m ago)   3h19m
kube-system   kube-scheduler-minikube            1/1     Running       1 (3h15m ago)   3h19m
kube-system   storage-provisioner                1/1     Running       4 (3h6m ago)    3h19m
web           web-consumer-5769f9f766-jclbz      1/1     Running       0               29s
web           web-consumer-5769f9f766-rjrkc      1/1     Running       0               26s
web           web-consumer-84fc79d94d-9ws49      1/1     Terminating   0               9m27s
web           web-consumer-84fc79d94d-gs6qn      1/1     Terminating   0               9m27s
```

- Проверим логи

```shell
kubectl logs -n web web-consumer-5769f9f766-jclbz
```

<details>
    <summary>Вывод команды</summary>

```text
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   122k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   119k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

</details>

#### Проблема решена

- Исправленный манифест [task.yaml](src/task.yaml)

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
