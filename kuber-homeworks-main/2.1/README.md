# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке MicroK8S](https://microk8s.io/docs/getting-started).
2. [Описание Volumes](https://kubernetes.io/docs/concepts/storage/volumes/).
3. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

### Решение 1

Создал [deployments_volume.yaml](src/deployments_volume.yaml)

```shell
ubuntu@VM104:~$ microk8s kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
netology-volume-687ff9677-x6wx2   2/2     Running   0          12m

```

Прочитаем информацию из файла в который пишет `busybox` из `multitool`

```shell
ubuntu@VM104:~$ microk8s kubectl exec netology-volume-687ff9677-x6wx2 -c network-multitool  -- tail -n 10 /share/output.txt
20230609081433
20230609081438
20230609081443
20230609081448
20230609081453
20230609081458
20230609081503
20230609081508
20230609081513
20230609081518
```
```shell
ubuntu@VM104:~$ microk8s kubectl exec netology-volume-687ff9677-x6wx2 -c network-multitool  -- tail -n 10 /share/output.txt
20230609081448
20230609081453
20230609081458
20230609081503
20230609081508
20230609081513
20230609081518
20230609081523
20230609081528
20230609081533
```



------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

### Решение 2

Создал [deployments_daemonset.yaml](src/deployments_daemonset.yaml)

```shell
ubuntu@VM104:~$ microk8s kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
netology-daemonset-cdw7s   1/1     Running   0          2m22s

```

Проверим возможность чтения изнутри пода

```shell
ubuntu@VM104:~$ microk8s kubectl exec netology-daemonset-cdw7s -it -- sh
/ # tail -n 10 /var/log/noda/syslog
Jun  9 08:29:02 VM104 systemd[6678]: run-containerd-runc-k8s.io-507a8c8a9ad2bc903a9fb3f68186e81a61e8099e17b3797683ba3c1aa989eae6-runc.Vt7xc9.mount: Succeeded.
Jun  9 08:29:02 VM104 systemd[1]: run-containerd-runc-k8s.io-507a8c8a9ad2bc903a9fb3f68186e81a61e8099e17b3797683ba3c1aa989eae6-runc.Vt7xc9.mount: Succeeded.
Jun  9 08:29:03 VM104 systemd[1]: run-containerd-runc-k8s.io-507a8c8a9ad2bc903a9fb3f68186e81a61e8099e17b3797683ba3c1aa989eae6-runc.rpJgOn.mount: Succeeded.
Jun  9 08:29:03 VM104 systemd[6678]: run-containerd-runc-k8s.io-507a8c8a9ad2bc903a9fb3f68186e81a61e8099e17b3797683ba3c1aa989eae6-runc.rpJgOn.mount: Succeeded.
Jun  9 08:29:03 VM104 systemd[1]: run-containerd-runc-k8s.io-ea9d107995fc5b6bfd325f479e678deaa38a37cd6cd9caa7b272b01f3dab43ff-runc.DoiIwB.mount: Succeeded.
Jun  9 08:29:03 VM104 systemd[6678]: run-containerd-runc-k8s.io-ea9d107995fc5b6bfd325f479e678deaa38a37cd6cd9caa7b272b01f3dab43ff-runc.DoiIwB.mount: Succeeded.
Jun  9 08:29:11 VM104 systemd[6678]: run-containerd-runc-k8s.io-ea9d107995fc5b6bfd325f479e678deaa38a37cd6cd9caa7b272b01f3dab43ff-runc.QpwXTx.mount: Succeeded.
Jun  9 08:29:11 VM104 systemd[1]: run-containerd-runc-k8s.io-ea9d107995fc5b6bfd325f479e678deaa38a37cd6cd9caa7b272b01f3dab43ff-runc.QpwXTx.mount: Succeeded.
Jun  9 08:29:12 VM104 systemd[6678]: run-containerd-runc-k8s.io-507a8c8a9ad2bc903a9fb3f68186e81a61e8099e17b3797683ba3c1aa989eae6-runc.mnf0WZ.mount: Succeeded.
Jun  9 08:29:12 VM104 systemd[1]: run-containerd-runc-k8s.io-507a8c8a9ad2bc903a9fb3f68186e81a61e8099e17b3797683ba3c1aa989eae6-runc.mnf0WZ.mount: Succeeded.
/ #

```

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------
