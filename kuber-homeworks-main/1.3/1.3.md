# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

### Ответ 1.

1. Создал [deployments.yaml](src/deployments.yaml)

```shell
ubuntu@VM104:~$ microk8s kubectl get deployment
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
multitool             1/1     1            1           61s
netology-deployment   1/1     1            1           61s
```

2. Меняем параметр `replicas: 2` и применяем 
```shell
ubuntu@VM104:~$ microk8s kubectl apply -f deployments.yaml
deployment.apps/netology-deployment configured
deployment.apps/multitool unchanged
```

3. Количество подов до и после масштабирования:

```shell
ubuntu@VM104:~$ microk8s kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
netology-deployment-66948488df-6smck   1/1     Running   0          8m35s
multitool-5c8cbc9b6c-798wn             1/1     Running   0          8m35s
```
```shell
ubuntu@VM104:~$ microk8s kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
netology-deployment-66948488df-6smck   1/1     Running   0          9m20s
multitool-5c8cbc9b6c-798wn             1/1     Running   0          9m20s
netology-deployment-66948488df-5nh9w   1/1     Running   0          4s

```

4. Создал Service

```shell
ubuntu@VM104:~$ microk8s kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.152.183.1    <none>        443/TCP   64d
nginx-svc    ClusterIP   10.152.183.52   <none>        80/TCP    1m
```

5. Проверяю доступ
```shell
ubuntu@VM104:~$ microk8s kubectl exec multitool-5c8cbc9b6c-798wn -- curl 10.152.183.52
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   706k      0 --:--:-- --:--:-- --:--:--  597k
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


------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.


### Ответ 2

1. Создал [deployments_nginx.yaml](src/deployments_nginx.yaml)
```shell
ubuntu@VM104:~$ microk8s kubectl apply -f deployments_nginx.yaml
deployment.apps/myapp-pod created

```
2. Проверяем лог пода
```shell
ubuntu@VM104:~$ microk8s kubectl logs myapp-pod-76f4f9959f-76wz8
Defaulted container "nginx" out of: nginx, init-myservice (init)
Error from server (BadRequest): container "nginx" in pod "myapp-pod-76f4f9959f-76wz8" is waiting to start: PodInitializing


```

3. Создал [myservice.yaml](src/myservice.yaml) 

Чтобы "магия" произошла нужно предварительно выполнить `microk8s enable dns`, иначе под не может обнаружить сервис.

4. Состояние пода до и после запуска сервиса
```shell
ubuntu@VM104:~$ microk8s kubectl get pods
NAME                         READY   STATUS     RESTARTS   AGE
myapp-pod-76f4f9959f-76wz8   0/1     Init:0/1   0          3m16s

```
```shell
ubuntu@VM104:~$ microk8s kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
myapp-pod-76f4f9959f-76wz8   1/1     Running   0          5m6s

```

------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------
