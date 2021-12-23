# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | Сложение числа и строки вызовет исключение, значение не будет присвоено  |
| Как получить для переменной `c` значение 12?  | Преобразовать `a` в строку: `c=str(a)+b` |
| Как получить для переменной `c` значение 3?  | Преобразовать `b` в число: `c=a+int(b)` |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
print ("Start searching for modifieded files ...")
bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
pwd = os.popen(bash_command[0]+"&& pwd").read().rstrip()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd + "/" + prepare_result)
        is_change = True
if is_change == False:
    print ("Modifieded files not found.")
```

### Вывод скрипта при запуске при тестировании:
```
vagrant@vagrant:~$ ./t422.py
Start searching for changed files ...
/home/vagrant/netology/sysadm-homeworks/04-script-03-yaml/README.md
/home/vagrant/netology/sysadm-homeworks/README.md
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

try:
    pwd = sys.argv[1]
except:
    sys.exit("\nUsage:\n   t423.py [path of repo]\n")

print ("Start searching for changed files ...")
bash_command = ["cd " + pwd, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
pwd = os.popen(bash_command[0]+"&& pwd").read().rstrip()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd + "/" + prepare_result)
        is_change = True
if is_change == False:
    print ("Modifieded files not found.")
```

### Вывод скрипта при запуске при тестировании:
```
vagrant@vagrant:~$ ./t423.py ~/netology/sysadm-homeworks/
Start searching for changed files ...
/home/vagrant/netology/sysadm-homeworks/04-script-03-yaml/README.md
/home/vagrant/netology/sysadm-homeworks/README.md

vagrant@vagrant:~$ ./t423.py ~/
Start searching for changed files ...
fatal: not a git repository (or any of the parent directories): .git
Modifieded files not found.

vagrant@vagrant:~$ ./t423.py

Usage:
   t423.py [path of repo]

```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time

srv_ip = {'drive.google.com':'', 'mail.google.com':'', 'google.com':''}
print("Start cheking IPs ...")
while(1==1):
    for srv in srv_ip.keys():
        ip = socket.gethostbyname(srv)
        if(ip == srv_ip[srv]):
            print(f'{srv} - {ip}')
        elif(srv_ip[srv]==''):
            srv_ip[srv] = ip
        else:
            print(f'[ERROR] {srv} IP mismatch: {srv_ip[srv]} {ip}')
            srv_ip[srv] = ip
    time.sleep(10)
```

### Вывод скрипта при запуске при тестировании:
```
vagrant@vagrant:~$ ./t424.py
Start cheking IPs ...
drive.google.com - 74.125.131.194
mail.google.com - 74.125.131.19
google.com - 216.239.38.120
drive.google.com - 74.125.131.194
mail.google.com - 74.125.131.19
google.com - 216.239.38.120
drive.google.com - 74.125.131.194
[ERROR] mail.google.com IP mismatch: 74.125.131.19 108.177.14.17
google.com - 216.239.38.120
drive.google.com - 74.125.131.194
[ERROR] mail.google.com IP mismatch: 108.177.14.17 108.177.14.18
google.com - 216.239.38.120
drive.google.com - 74.125.131.194
mail.google.com - 108.177.14.18
google.com - 216.239.38.120
drive.google.com - 74.125.131.194
mail.google.com - 108.177.14.18
google.com - 216.239.38.120
drive.google.com - 74.125.131.194
mail.google.com - 108.177.14.18
google.com - 216.239.38.120
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 

### Ваш скрипт:
```python
???
```

### Вывод скрипта при запуске при тестировании:
```
???
```
