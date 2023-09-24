# Домашнее задание к занятию «Как работает сеть в K8s»

## Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).

---

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

### Решение

- На развернутом кластере создадим deployment приложений и соответствующие svc в неймспейсе `app` из манифеста [deployment.yaml](src/Deployment/deployment.yaml). В качестве образа используем `network-multitool`.

```shell
kubectl create namespace app
kubectl apply -f deployment.yaml
```

```text
namespace/app created
deployment.apps/frontend created
service/frontend created
deployment.apps/backend created
service/backend created
deployment.apps/cache created
service/cache created
```

- Проверим deployment и svc

```shell
kubectl get -n app deployments
kubectl get -n app svc
```

```text
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
backend    1/1     1            1           75s
cache      1/1     1            1           75s
frontend   1/1     1            1           75s
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend    ClusterIP   10.233.15.217   <none>        80/TCP    75s
cache      ClusterIP   10.233.7.206    <none>        80/TCP    75s
frontend   ClusterIP   10.233.20.245   <none>        80/TCP    75s
```

- Создадим политики из манифеста [networkpolicy.yaml](src/NetworkPolicy/networkpolicy.yaml), чтобы обеспечить доступ `frontend` -> `backend` -> `cache`.

```shell
kubectl apply -f networkpolicy.yaml
```

```text
networkpolicy.networking.k8s.io/ingress-deny-all created
networkpolicy.networking.k8s.io/allow-frontend-to-backend created
networkpolicy.networking.k8s.io/allow-backend-to-cache created
```

- Проверим networkpolicy

```shell
kubectl get -n app networkpolicy
```

```text
NAME                        POD-SELECTOR   AGE
allow-backend-to-cache      app=cache      100s
allow-frontend-to-backend   app=backend    100s
ingress-deny-all            <none>         101s
```

- Проверим разрешения и запреты трафика. Запустим скрипт [test.sh](src/test.sh)

```text
[frontend to frontend]
command terminated with exit code 28

[frontend to backend]
Praqma Network MultiTool (with NGINX) - backend-6478c64696-vqlsk - 10.233.105.132

[frontend to cache]
command terminated with exit code 28

[backend to frontend]
command terminated with exit code 28

[backend to backend]
command terminated with exit code 28

[backend to cache]
Praqma Network MultiTool (with NGINX) - cache-575bd6d866-sc827 - 10.233.105.133

[cache to frontend]
command terminated with exit code 28

[cache to backend]
command terminated with exit code 28

[cache to cache]
command terminated with exit code 28
```

- Посмотрим на поды, а именно на их имена и IP адреса

```shell
kubectl get -n app pods -o wide
```

```text
NAME                        READY   STATUS    RESTARTS   AGE    IP               NODE      NOMINATED NODE   READINESS GATES
backend-6478c64696-vqlsk    1/1     Running   0          32m   10.233.105.132   worker1   <none>           <none>
cache-575bd6d866-sc827      1/1     Running   0          32m   10.233.105.133   worker1   <none>           <none>
frontend-7c96b4cbfb-xxtk7   1/1     Running   0          32m   10.233.105.131   worker1   <none>           <none>
```

- И в начале не показал поды в неймспейсе `kube-system`

```shell
kubectl get -n kube-system pods
```

```text
NAME                                       READY   STATUS    RESTARTS       AGE
calico-kube-controllers-5fb8ccdcd6-fqzrv   1/1     Running   1 (157m ago)   178m
calico-node-89d4k                          1/1     Running   1 (157m ago)   179m
calico-node-ft2dk                          1/1     Running   0              179m
coredns-67cb94d654-d4k2t                   1/1     Running   0              177m
coredns-67cb94d654-vjdjq                   1/1     Running   1 (157m ago)   178m
dns-autoscaler-7b6c6d8b5b-27f5l            1/1     Running   1              178m
kube-apiserver-master                      1/1     Running   2 (157m ago)   3h1m
kube-controller-manager-master             1/1     Running   4 (157m ago)   3h1m
kube-proxy-lp5c7                           1/1     Running   1 (157m ago)   164m
kube-proxy-rg5sm                           1/1     Running   0              164m
kube-scheduler-master                      1/1     Running   2 (157m ago)   3h1m
nginx-proxy-worker1                        1/1     Running   0              3h
nodelocaldns-gzdrw                         1/1     Running   0              177m
nodelocaldns-n4vq4                         1/1     Running   3 (154m ago)   177m
```

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
