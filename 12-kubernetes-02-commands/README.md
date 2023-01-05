# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

### Ответ

```shell
root@VM102 /home/ubuntu/HW.12.02
> # kubectl apply -f hello-world-dep.yaml
deployment.apps/hello-world-deployment created

root@VM102 /home/ubuntu/HW.12.02
> # kubectl get deploy
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
hello-world-deployment   2/2     2            2           14s

root@VM102 /home/ubuntu/HW.12.02
> # kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
hello-world-deployment-6b4d99f98f-gvtn4   1/1     Running   0          77s
hello-world-deployment-6b4d99f98f-q8xts   1/1     Running   0          77s
```

## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)


### Ответ
- Конфиги для создания сервисного аккаунта и роли:
  - [ServiceAccount.yaml](src/ServiceAccount.yaml) 
  - [Role.yaml](src/role.yaml)
  - [RoleBinding.yaml](src/RoleBinding.yaml)

- Создадим учетную запись, роль и связываю аккаунт с ролью:
```shell
root@VM102 /home/ubuntu/HW.12.02
> # kubectl apply -f ServiceAccount.yaml
serviceaccount/loguser created

root@VM102 /home/ubuntu/HW.12.02
> # kubectl apply -f role.yaml
role.rbac.authorization.k8s.io/loguser-role created

root@VM102 /home/ubuntu/HW.12.02
> # kubectl apply -f RoleBinding.yaml
rolebinding.rbac.authorization.k8s.io/pods-logs created
```

Проверим доступ и права доступа от имени `loguser`
- `kubectl get pods --as=system:serviceaccount:default:loguser`
```shell
root@VM102 /home/ubuntu/HW.12.02
> # kubectl get pods --as=system:serviceaccount:default:loguser
NAME                                      READY   STATUS    RESTARTS   AGE
hello-world-deployment-6b4d99f98f-gvtn4   1/1     Running   0          23m
hello-world-deployment-6b4d99f98f-q8xts   1/1     Running   0          23m
```
- `kubectl describe pod --as=system:serviceaccount:default:loguser`
<details>
    <summary>Вывод команды</summary>

```shell
root@VM102 /home/ubuntu/HW.12.02
> # kubectl describe pod --as=system:serviceaccount:default:loguser
Name:             hello-world-deployment-6b4d99f98f-gvtn4
Namespace:        default
Priority:         0
Service Account:  default
Node:             vm102/192.168.2.118
Start Time:       Fri, 06 Jan 2023 00:59:55 +0500
Labels:           app=hello-world-deployment
                  pod-template-hash=6b4d99f98f
Annotations:      cni.projectcalico.org/containerID: fb4424caf93716c5aed4a76709f4cfd9ac2b9debfedd5af0732453258481391c
                  cni.projectcalico.org/podIP: 10.244.31.5/32
                  cni.projectcalico.org/podIPs: 10.244.31.5/32
Status:           Running
IP:               10.244.31.5
IPs:
  IP:           10.244.31.5
Controlled By:  ReplicaSet/hello-world-deployment-6b4d99f98f
Containers:
  hello-world-app:
    Container ID:   docker://9772a34977c62b8730791e63e12514f1e783c9a884597504a6193fd720659001
    Image:          k8s.gcr.io/echoserver:1.4
    Image ID:       docker-pullable://k8s.gcr.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 06 Jan 2023 00:59:56 +0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8bnl (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-c8bnl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:             hello-world-deployment-6b4d99f98f-q8xts
Namespace:        default
Priority:         0
Service Account:  default
Node:             vm102/192.168.2.118
Start Time:       Fri, 06 Jan 2023 00:59:55 +0500
Labels:           app=hello-world-deployment
                  pod-template-hash=6b4d99f98f
Annotations:      cni.projectcalico.org/containerID: 4d4c236f9c5870c6b12430c03a1e646f586eb250a4d5e84697dee1ee0a1294cc
                  cni.projectcalico.org/podIP: 10.244.31.4/32
                  cni.projectcalico.org/podIPs: 10.244.31.4/32
Status:           Running
IP:               10.244.31.4
IPs:
  IP:           10.244.31.4
Controlled By:  ReplicaSet/hello-world-deployment-6b4d99f98f
Containers:
  hello-world-app:
    Container ID:   docker://5edef10a1d0dae5f217df1761fb5e362d82ee3c1c2fba3fef93b2adbd286c39d
    Image:          k8s.gcr.io/echoserver:1.4
    Image ID:       docker-pullable://k8s.gcr.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 06 Jan 2023 00:59:56 +0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-lxw5c (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-lxw5c:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```
</details>

Проверим, что отсутствует доступ, например, к `secrets` от имени `loguser`
- `kubectl -n default get secrets --as=system:serviceaccount:default:loguser`
```shell
root@VM102 /home/ubuntu/HW.12.02
> # kubectl -n default get secrets --as=system:serviceaccount:default:loguser
Error from server (Forbidden): secrets is forbidden: User "system:serviceaccount:default:loguser" cannot list resource "secrets" in API group "" in the namespace "default"
```

## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

### Ответ

Изменим количество реплик "на лету" и проверим статус подов
```shell
root@VM102 /home/ubuntu/HW.12.02
> # kubectl scale deployment hello-world-deployment --replicas=5
deployment.apps/hello-world-deployment scaled

root@VM102 /home/ubuntu/HW.12.02
> # kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
hello-world-deployment-6b4d99f98f-5rzfq   1/1     Running   0          20s
hello-world-deployment-6b4d99f98f-6qvxr   1/1     Running   0          20s
hello-world-deployment-6b4d99f98f-cxzbz   1/1     Running   0          20s
hello-world-deployment-6b4d99f98f-gvtn4   1/1     Running   0          31m
hello-world-deployment-6b4d99f98f-q8xts   1/1     Running   0          31m
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
