# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Решение 1

1. Создал [deployments_pvc_volume.yaml](src/deployments_pvc_volume.yaml)
```shell
ubuntu@VM104:~$ microk8s kubectl apply -f  deployments_pvc_volume.yaml
deployment.apps/netology-volume-pvc created
ubuntu@VM104:~$ microk8s kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
netology-volume-pvc-7f58bfd9d9-w2ffh   0/2     Pending   0          21s

```
Статус `pending` потому, что нет еще `pv` и `pvc`

2. Создал [pv_volume.yaml](src/pv_volume.yaml) и [pvc_volume.yaml](src/pvc_volume.yaml)
```shell
ubuntu@VM104:~$ microk8s kubectl get pv,pvc,pod
NAME                  CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   REASON   AGE
persistentvolume/pv   2Gi        RWO            Delete           Bound    default/pvc-vol                           52s

NAME                            STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc-vol   Bound    pv       2Gi        RWO                           59s

NAME                                      READY   STATUS    RESTARTS   AGE
pod/netology-volume-pvc-7f58bfd9d9-w2ffh   2/2     Running   0          5m38s

```

Всё создалось и запустилось

3. Проверяем, что `multitool` может читать файл в который пишет `busybox`
```shell
ubuntu@VM104:~$ microk8s kubectl exec  netology-volume-pvc-7f58bfd9d9-w2ffh  -c network-multitool  -- tail -n 10 /share/output.txt
Sat Jun 10 20:25:04 UTC 2023
Sat Jun 10 20:25:09 UTC 2023
Sat Jun 10 20:25:14 UTC 2023
Sat Jun 10 20:25:19 UTC 2023
Sat Jun 10 20:25:24 UTC 2023
Sat Jun 10 20:25:29 UTC 2023
Sat Jun 10 20:25:34 UTC 2023
Sat Jun 10 20:25:39 UTC 2023
Sat Jun 10 20:25:44 UTC 2023
Sat Jun 10 20:25:49 UTC 2023

```

4. Удаляем Deployment и PVC
```shell
ubuntu@VM104:~$ microk8s kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
netology-volume-pvc   1/1     1            1           18m

ubuntu@VM104:~$ microk8s kubectl delete deployments netology-volume-pvc
deployment.apps "netology-volume-pvc" deleted

ubuntu@VM104:~$ microk8s kubectl get pvc
NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-vol   Bound    pv       2Gi        RWO                           14m

ubuntu@VM104:~$ microk8s kubectl delete pvc pvc-vol
persistentvolumeclaim "pvc-vol" deleted

ubuntu@VM104:~$ microk8s kubectl get pv
No resources found

ubuntu@VM104:~$ microk8s kubectl get all
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   67d

```

После удаления `Deployments` удаляется `pod` и перестает идти запись в файл.
Далее, после удаления `pvc` удаляется `pv` и удаляется файл в `hostPath` потому, что в параметре `persistentVolumeReclaimPolicy` установлено значение `Delete`. Если установить значение `Retain`, то `pv` сохраняется и данные на ноде тоже сохраняются.

```shell
ubuntu@VM104:~$ cat /tmp/pv/output.txt
cat: /tmp/pv/output.txt: No such file or directory

```
5. Манифесты
- [deployments_pvc_volume.yaml](src/deployments_pvc_volume.yaml)
- [pvc_volume.yaml](src/pvc_volume.yaml)
- [pv_volume.yaml](src/pv_volume.yaml)

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Решение 2

1. Включил и настроил NFS-сервер по [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs).
- Для отладки работы NFS в Microk8s помогут команды:
```shell
microk8s kubectl logs --selector app=csi-nfs-controller -n kube-system -c nfs
microk8s kubectl logs --selector app=csi-nfs-node -n kube-system -c nfs
```

2. Создал `Deployment`, `pvc` и `sc` (см.п.4)
```shell
ubuntu@VM104:~$ microk8s kubectl get sc,pvc,pod
NAME                                  PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/nfs-csi   nfs.csi.k8s.io   Delete          Immediate           false                  3m12s

NAME                           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/my-pvc   Bound    pvc-af7c1421-419a-48cc-bfeb-0525b490c9ad   5Gi        RWO            nfs-csi        3m3s

NAME                                        READY   STATUS    RESTARTS   AGE
pod/netology-volume-pvc2-58cfb94877-d78bc   2/2     Running   0          23s

```
3. Проверим возможность чтения и записи изнутри пода `multitool`
```shell
ubuntu@VM104:~$ microk8s kubectl exec netology-volume-pvc2-58cfb94877-d78bc -c network-multitool  -- tail -n 10 /share/output.txt
Mon Jun 12 12:42:25 UTC 2023
Mon Jun 12 12:42:30 UTC 2023
Mon Jun 12 12:42:35 UTC 2023
Mon Jun 12 12:42:40 UTC 2023
Mon Jun 12 12:42:45 UTC 2023
Mon Jun 12 12:42:51 UTC 2023
Mon Jun 12 12:42:56 UTC 2023
Mon Jun 12 12:43:01 UTC 2023
Mon Jun 12 12:43:06 UTC 2023
Mon Jun 12 12:43:11 UTC 2023

```
5. Манифесты
- [deployments_pvc_volume2.yaml](src/deployments_pvc_volume2.yaml)
- [pvc_volume2.yaml](src/pvc_volume2.yaml)
- [sc-vol-nfs.yaml](src/sc-vol-nfs.yaml)
------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
