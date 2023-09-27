# Домашнее задание к занятию «Организация сети»

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию). 
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории. 
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашнее задание по теме «Облачные провайдеры и синтаксис Terraform». Заранее выберите регион (в случае AWS) и зону.

---
### Задание 1. Yandex Cloud 

**Что нужно сделать**

1. Создать пустую VPC. Выбрать зону.

2. Публичная подсеть.

* Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
* Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.
* Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.

3. Приватная подсеть.

* Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
* Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
* Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.

Resource Terraform для Yandex Cloud:

* [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
* [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
* [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

### Решение 1. Yandex Cloud

* Конфигурационные файлы `terraform` созданы ([файлы тут](./terraform_config/)).

* Запустим создание ресурсов

```shell
terraform apply --auto-approve
```

<details>
    <summary>Вывод экрана</summary>

```shell
texdata.yandex_compute_image.ubuntu: Reading...
data.yandex_compute_image.ubuntu: Read complete after 1s [id=fd8o6khjbdv3f1suqf69]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.private-host will be created
  + resource "yandex_compute_instance" "private-host" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa ******
            EOT
        }
      + name                      = "private-host"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8o6khjbdv3f1suqf69"
              + name        = "root-private-host"
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-nvme"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.public-host will be created
  + resource "yandex_compute_instance" "public-host" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa ******
            EOT
        }
      + name                      = "public-host"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8o6khjbdv3f1suqf69"
              + name        = "root-public-host"
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-nvme"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.public-nat will be created
  + resource "yandex_compute_instance" "public-nat" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa ******
            EOT
        }
      + name                      = "public-nat"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80mrhj8fl2oe87o4e1"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = "192.168.10.254"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_route_table.private-route-table will be created
  + resource "yandex_vpc_route_table" "private-route-table" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + labels     = (known after apply)
      + network_id = (known after apply)

      + static_route {
          + destination_prefix = "0.0.0.0/0"
          + next_hop_address   = "192.168.10.254"
        }
    }

  # yandex_vpc_subnet.private will be created
  + resource "yandex_vpc_subnet" "private" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "private_subnet"
      + network_id     = (known after apply)
      + route_table_id = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.public will be created
  + resource "yandex_vpc_subnet" "public" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "public_subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_private-host = (known after apply)
  + external_ip_address_public-host  = (known after apply)
  + external_ip_address_public-nat   = (known after apply)
  + internal_ip_address_private-host = (known after apply)
  + internal_ip_address_public-host  = (known after apply)
  + internal_ip_address_public-nat   = "192.168.10.254"
yandex_vpc_network.default: Creating...
yandex_vpc_network.default: Creation complete after 2s [id=enprasn52j9c505mlqlf]
yandex_vpc_subnet.public: Creating...
yandex_vpc_route_table.private-route-table: Creating...
yandex_vpc_subnet.public: Creation complete after 1s [id=e9bb7ea8t0ihdnctleja]
yandex_compute_instance.public-host: Creating...
yandex_compute_instance.public-nat: Creating...
yandex_vpc_route_table.private-route-table: Creation complete after 2s [id=enph8b6ibark1tjtl4re]
yandex_vpc_subnet.private: Creating...
yandex_vpc_subnet.private: Creation complete after 1s [id=e9bnifb42luvbaq07hru]
yandex_compute_instance.private-host: Creating...
yandex_compute_instance.public-host: Still creating... [10s elapsed]
yandex_compute_instance.public-nat: Still creating... [10s elapsed]
yandex_compute_instance.private-host: Still creating... [10s elapsed]
yandex_compute_instance.public-nat: Still creating... [20s elapsed]
yandex_compute_instance.public-host: Still creating... [20s elapsed]
yandex_compute_instance.private-host: Still creating... [20s elapsed]
yandex_compute_instance.public-host: Still creating... [30s elapsed]
yandex_compute_instance.public-nat: Still creating... [30s elapsed]
yandex_compute_instance.private-host: Still creating... [30s elapsed]
yandex_compute_instance.public-nat: Still creating... [40s elapsed]
yandex_compute_instance.public-host: Still creating... [40s elapsed]
yandex_compute_instance.private-host: Still creating... [40s elapsed]
yandex_compute_instance.public-host: Still creating... [50s elapsed]
yandex_compute_instance.public-nat: Still creating... [50s elapsed]
yandex_compute_instance.private-host: Still creating... [50s elapsed]
yandex_compute_instance.public-nat: Still creating... [1m0s elapsed]
yandex_compute_instance.public-host: Still creating... [1m0s elapsed]
yandex_compute_instance.private-host: Still creating... [1m0s elapsed]
yandex_compute_instance.public-host: Still creating... [1m10s elapsed]
yandex_compute_instance.public-nat: Still creating... [1m10s elapsed]
yandex_compute_instance.private-host: Still creating... [1m10s elapsed]
yandex_compute_instance.public-host: Creation complete after 1m13s [id=fhmt9mum201j4leegii6]
yandex_compute_instance.private-host: Creation complete after 1m11s [id=fhm34d4c1q23qugo7ssj]
yandex_compute_instance.public-nat: Creation complete after 1m15s [id=fhmn7b4a5hjhadn0rhgf]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_private-host = ""
external_ip_address_public-host = "51.250.10.39"
external_ip_address_public-nat = "51.250.1.171"
internal_ip_address_private-host = "192.168.20.30"
internal_ip_address_public-host = "192.168.10.16"
internal_ip_address_public-nat = "192.168.10.254"
```

</details>
  
* Подключимся по ssh к ВМ в публичной сети и проверим наличие интернета

```shell
ssh ubuntu@51.250.10.39
```

<details>
    <summary>Вывод экрана</summary>

```shell
The authenticity of host '51.250.10.39 (51.250.10.39)' can't be established.
ECDSA key fingerprint is SHA256:UMpwDgC/mL7Yvx0qJRYuDYL4tSi3yQuuxbSYU/RVAt4.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '51.250.10.39' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-163-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@fhmt9mum201j4leegii6:~$ ping ya.ru
PING ya.ru (77.88.55.242) 56(84) bytes of data.
64 bytes from ya.ru (77.88.55.242): icmp_seq=1 ttl=56 time=4.17 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=2 ttl=56 time=3.48 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=3 ttl=56 time=3.56 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=4 ttl=56 time=3.54 ms
^C
--- ya.ru ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 3.482/3.688/4.172/0.280 ms
```

</details>

* Подключимся по ssh к ВМ в приватной сети из ВМ в публичной сети и проверим наличие интернета

```shell
ssh ubuntu@192.168.20.30
```

<details>
    <summary>Вывод экрана</summary>

```shell
The authenticity of host '192.168.20.30 (192.168.20.30)' can't be established.
ECDSA key fingerprint is SHA256:qJvDJiewte88Ffo575Z0AEglkbuhp09+BcR0w3NAbVU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.20.30' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-163-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@fhm34d4c1q23qugo7ssj:~$ ping ya.ru
PING ya.ru (77.88.55.242) 56(84) bytes of data.
64 bytes from ya.ru (77.88.55.242): icmp_seq=1 ttl=52 time=5.79 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=2 ttl=52 time=4.07 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=3 ttl=52 time=4.13 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=4 ttl=52 time=3.97 ms
^C
--- ya.ru ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 3.972/4.489/5.790/0.752 ms
```  

</details>

* Уничтожим ресурсы в YC

```shell
terraform destroy --auto-approve
```

* жопиздан! <sup id="a1">[1](#f1)</sup>

---
### Задание 2. AWS* (задание со звёздочкой)

Это необязательное задание. Его выполнение не влияет на получение зачёта по домашней работе.

**Что нужно сделать**

1. Создать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 10.10.1.0/24.
 - Разрешить в этой subnet присвоение public IP по-умолчанию.
 - Создать Internet gateway.
 - Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
 - Создать security group с разрешающими правилами на SSH и ICMP. Привязать эту security group на все, создаваемые в этом ДЗ, виртуалки.
 - Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться, что есть доступ к интернету.
 - Добавить NAT gateway в public subnet.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 10.10.2.0/24.
 - Создать отдельную таблицу маршрутизации и привязать её к private подсети.
 - Добавить Route, направляющий весь исходящий трафик private сети в NAT.
 - Создать виртуалку в приватной сети.
 - Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети, и убедиться, что с виртуалки есть выход в интернет.

Resource Terraform:

1. [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc).
1. [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet).
1. [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway).

### Правила приёма работы

Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

<b id="f1">1</b> *Юмор*:  
Каждую пятницу, покидая офис, шеф громко произносил: жопиздан!  
Охрана напрягалась, уборщица крестилась...  
И только переводчица Лена тихонько поправляла: **Job is done**. [↩](#a1)