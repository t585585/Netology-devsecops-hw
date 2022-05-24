# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

## Ответ (Вариант с ЯО)

![.](img/img_1.jpg)

## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  

## Ответ

1. Выполните `terraform init`
   <Details>
   <summary>Спойлер</summary>
   
   ```shell
   vagrant@vagrant:~/hw73$ terraform init
   Initializing modules...
   
   Initializing the backend...
   
   Successfully configured the backend "s3"! Terraform will automatically
   use this backend unless the backend configuration changes.
   
   Initializing provider plugins...
   - Finding yandex-cloud/yandex versions matching "0.61.0, ~> 0.61.0"...
   - Installing yandex-cloud/yandex v0.61.0...
   - Installed yandex-cloud/yandex v0.61.0 (self-signed, key ID E40F590B50BB8E40)
   
   Partner and community providers are signed by their developers.
   If you'd like to know more about provider signing, you can read about it here:
   https://www.terraform.io/docs/cli/plugins/signing.html
   
   Terraform has created a lock file .terraform.lock.hcl to record the provider
   selections it made above. Include this file in your version control repository
   so that Terraform can guarantee to make the same selections by default when
   you run "terraform init" in the future.
   
   Terraform has been successfully initialized!
   
   You may now begin working with Terraform. Try running "terraform plan" to see
   any changes that are required for your infrastructure. All Terraform commands
   should now work.
   
   If you ever set or change modules or backend configuration for Terraform,
   rerun this command to reinitialize your working directory. If you forget, other
   commands will detect it and remind you to do so if necessary.
   ```
   </Details>

2. Создайте два воркспейса `stage` и `prod`.
   <Details>
   <summary>Спойлер</summary>
   
   ```shell
   vagrant@vagrant:~/hw73$ terraform workspace new prod
   Created and switched to workspace "prod"!
   
   You're now on a new, empty workspace. Workspaces isolate their state,
   so if you run "terraform plan" Terraform will not see any existing state
   for this configuration.
   ```
   ```shell
   vagrant@vagrant:~/hw73$ terraform workspace new stage
   Created and switched to workspace "stage"!
   
   You're now on a new, empty workspace. Workspaces isolate their state,
   so if you run "terraform plan" Terraform will not see any existing state
   for this configuration.
   ```
   </Details>

3. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные `instance_type`.

```terraform
resource yandex_compute_instance "count_vm" {
   count = local.instance_type_count[terraform.workspace]
   ...
}
```
4. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
```terraform
locals {
   instance_type_count = {
      stage = 1
      prod  = 2
   }
   ...
}
```
```terraform
resource yandex_compute_instance "count_vm" {
   count = local.instance_type_count[terraform.workspace]
   ...
}
```
5. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
```terraform
locals {
   instance_type_for-each = {
    stage = toset(["vm01"]),
    prod  = toset(["vm01", "vm02", "vm03"])
   }
   ...
}
```
```terraform
resource yandex_compute_instance "for-each_vm" {
   for_each = local.instance_type_for-each[terraform.workspace]
   ...
}
```
6. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
```terraform
resource yandex_compute_instance "for-each_vm" {
   ...
   lifecycle {
      create_before_destroy = true
   }
   ...
}
```
7. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
```shell
vagrant@vagrant:~/hw73$ terraform workspace list
  default
* prod
  stage
```
* Вывод команды `terraform plan` для воркспейса `prod`. 
   <Details>
   <summary>Спойлер</summary>
  
   ```shell
   vagrant@vagrant:~/hw73$ terraform plan
   
   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create
   
   Terraform will perform the following actions:
   
     # yandex_compute_instance.count_vm[0] will be created
     + resource "yandex_compute_instance" "count_vm" {
         + created_at                = (known after apply)
         + folder_id                 = (known after apply)
         + fqdn                      = (known after apply)
         + hostname                  = (known after apply)
         + id                        = (known after apply)
         + metadata                  = {
             + "ssh-keys" = <<-EOT
                   ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC82H6GGNVhzPlQbOvXGbmjzneF3YufolwYqNj2Z9TMED0erNTQUO2X2J0zFEBtaYNn9/aLsU8OhBOX4tU31aJNLuf9TW7oewgY23aN2LGUUX8giHZdjqD4yfjmwyojnbFsD2gj7slSF1bjbieAZ7LYXrpg62082FNJrFb5BM1yMFItrSerYNynkJm//JxyWg4XkvaUz6z+3bzxcJos+goTHzNlrmzpKJ4Upywf4r2nACALjhUnbqNdA1Y/0P+dP7E7ZwyWmp55pdJTbB3//rES6+nO45Uj1YocxM6KNd5g1L0TGh8TH3lCUnSIjY2uarh9wRVfmX610iHShbvLJrQCvszaUQ2i9zIqNeX/nkMFHLVMGV36Nq0m2kFZAScQjUtK/OScxuL4lF5aDk2T7NpRpjGdJhha9I9wOpN9FQ/k/aapDZCYUROh8F1pptXG0bQUoiwY6fTxQ8p+dZvlYTmFQMPVPdhVj74X8l2AcQCwxYlZN+pR2fsCIoIQ7cPtFzk= vagrant@vagrant
               EOT
           }
         + name                      = "count-vm01"
         + network_acceleration_type = "standard"
         + platform_id               = "standard-v1"
         + service_account_id        = (known after apply)
         + status                    = (known after apply)
         + zone                      = (known after apply)
   
         + boot_disk {
             + auto_delete = true
             + device_name = (known after apply)
             + disk_id     = (known after apply)
             + mode        = (known after apply)
   
             + initialize_params {
                 + description = (known after apply)
                 + image_id    = "fd8ciuqfa001h8s9sa7i"
                 + name        = (known after apply)
                 + size        = 20
                 + snapshot_id = (known after apply)
                 + type        = "network-hdd"
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
   
         + placement_policy {
             + placement_group_id = (known after apply)
           }
   
         + resources {
             + core_fraction = 5
             + cores         = 2
             + memory        = 2
           }
   
         + scheduling_policy {
             + preemptible = (known after apply)
           }
       }
   
     # yandex_compute_instance.count_vm[1] will be created
     + resource "yandex_compute_instance" "count_vm" {
         + created_at                = (known after apply)
         + folder_id                 = (known after apply)
         + fqdn                      = (known after apply)
         + hostname                  = (known after apply)
         + id                        = (known after apply)
         + metadata                  = {
             + "ssh-keys" = <<-EOT
                   ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC82H6GGNVhzPlQbOvXGbmjzneF3YufolwYqNj2Z9TMED0erNTQUO2X2J0zFEBtaYNn9/aLsU8OhBOX4tU31aJNLuf9TW7oewgY23aN2LGUUX8giHZdjqD4yfjmwyojnbFsD2gj7slSF1bjbieAZ7LYXrpg62082FNJrFb5BM1yMFItrSerYNynkJm//JxyWg4XkvaUz6z+3bzxcJos+goTHzNlrmzpKJ4Upywf4r2nACALjhUnbqNdA1Y/0P+dP7E7ZwyWmp55pdJTbB3//rES6+nO45Uj1YocxM6KNd5g1L0TGh8TH3lCUnSIjY2uarh9wRVfmX610iHShbvLJrQCvszaUQ2i9zIqNeX/nkMFHLVMGV36Nq0m2kFZAScQjUtK/OScxuL4lF5aDk2T7NpRpjGdJhha9I9wOpN9FQ/k/aapDZCYUROh8F1pptXG0bQUoiwY6fTxQ8p+dZvlYTmFQMPVPdhVj74X8l2AcQCwxYlZN+pR2fsCIoIQ7cPtFzk= vagrant@vagrant
               EOT
           }
         + name                      = "count-vm02"
         + network_acceleration_type = "standard"
         + platform_id               = "standard-v1"
         + service_account_id        = (known after apply)
         + status                    = (known after apply)
         + zone                      = (known after apply)
   
         + boot_disk {
             + auto_delete = true
             + device_name = (known after apply)
             + disk_id     = (known after apply)
             + mode        = (known after apply)
   
             + initialize_params {
                 + description = (known after apply)
                 + image_id    = "fd8ciuqfa001h8s9sa7i"
                 + name        = (known after apply)
                 + size        = 20
                 + snapshot_id = (known after apply)
                 + type        = "network-hdd"
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
   
         + placement_policy {
             + placement_group_id = (known after apply)
           }
   
         + resources {
             + core_fraction = 5
             + cores         = 2
             + memory        = 2
           }
   
         + scheduling_policy {
             + preemptible = (known after apply)
           }
       }
   
     # yandex_compute_instance.for-each_vm["vm01"] will be created
     + resource "yandex_compute_instance" "for-each_vm" {
         + created_at                = (known after apply)
         + folder_id                 = (known after apply)
         + fqdn                      = (known after apply)
         + hostname                  = (known after apply)
         + id                        = (known after apply)
         + metadata                  = {
             + "ssh-keys" = <<-EOT
                   ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC82H6GGNVhzPlQbOvXGbmjzneF3YufolwYqNj2Z9TMED0erNTQUO2X2J0zFEBtaYNn9/aLsU8OhBOX4tU31aJNLuf9TW7oewgY23aN2LGUUX8giHZdjqD4yfjmwyojnbFsD2gj7slSF1bjbieAZ7LYXrpg62082FNJrFb5BM1yMFItrSerYNynkJm//JxyWg4XkvaUz6z+3bzxcJos+goTHzNlrmzpKJ4Upywf4r2nACALjhUnbqNdA1Y/0P+dP7E7ZwyWmp55pdJTbB3//rES6+nO45Uj1YocxM6KNd5g1L0TGh8TH3lCUnSIjY2uarh9wRVfmX610iHShbvLJrQCvszaUQ2i9zIqNeX/nkMFHLVMGV36Nq0m2kFZAScQjUtK/OScxuL4lF5aDk2T7NpRpjGdJhha9I9wOpN9FQ/k/aapDZCYUROh8F1pptXG0bQUoiwY6fTxQ8p+dZvlYTmFQMPVPdhVj74X8l2AcQCwxYlZN+pR2fsCIoIQ7cPtFzk= vagrant@vagrant
               EOT
           }
         + name                      = "for-each-vm01"
         + network_acceleration_type = "standard"
         + platform_id               = "standard-v1"
         + service_account_id        = (known after apply)
         + status                    = (known after apply)
         + zone                      = (known after apply)
   
         + boot_disk {
             + auto_delete = true
             + device_name = (known after apply)
             + disk_id     = (known after apply)
             + mode        = (known after apply)
   
             + initialize_params {
                 + description = (known after apply)
                 + image_id    = "fd8ciuqfa001h8s9sa7i"
                 + name        = (known after apply)
                 + size        = 20
                 + snapshot_id = (known after apply)
                 + type        = "network-hdd"
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
   
         + placement_policy {
             + placement_group_id = (known after apply)
           }
   
         + resources {
             + core_fraction = 100
             + cores         = 2
             + memory        = 2
           }
   
         + scheduling_policy {
             + preemptible = (known after apply)
           }
       }
   
     # yandex_compute_instance.for-each_vm["vm02"] will be created
     + resource "yandex_compute_instance" "for-each_vm" {
         + created_at                = (known after apply)
         + folder_id                 = (known after apply)
         + fqdn                      = (known after apply)
         + hostname                  = (known after apply)
         + id                        = (known after apply)
         + metadata                  = {
             + "ssh-keys" = <<-EOT
                   ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC82H6GGNVhzPlQbOvXGbmjzneF3YufolwYqNj2Z9TMED0erNTQUO2X2J0zFEBtaYNn9/aLsU8OhBOX4tU31aJNLuf9TW7oewgY23aN2LGUUX8giHZdjqD4yfjmwyojnbFsD2gj7slSF1bjbieAZ7LYXrpg62082FNJrFb5BM1yMFItrSerYNynkJm//JxyWg4XkvaUz6z+3bzxcJos+goTHzNlrmzpKJ4Upywf4r2nACALjhUnbqNdA1Y/0P+dP7E7ZwyWmp55pdJTbB3//rES6+nO45Uj1YocxM6KNd5g1L0TGh8TH3lCUnSIjY2uarh9wRVfmX610iHShbvLJrQCvszaUQ2i9zIqNeX/nkMFHLVMGV36Nq0m2kFZAScQjUtK/OScxuL4lF5aDk2T7NpRpjGdJhha9I9wOpN9FQ/k/aapDZCYUROh8F1pptXG0bQUoiwY6fTxQ8p+dZvlYTmFQMPVPdhVj74X8l2AcQCwxYlZN+pR2fsCIoIQ7cPtFzk= vagrant@vagrant
               EOT
           }
         + name                      = "for-each-vm02"
         + network_acceleration_type = "standard"
         + platform_id               = "standard-v1"
         + service_account_id        = (known after apply)
         + status                    = (known after apply)
         + zone                      = (known after apply)
   
         + boot_disk {
             + auto_delete = true
             + device_name = (known after apply)
             + disk_id     = (known after apply)
             + mode        = (known after apply)
   
             + initialize_params {
                 + description = (known after apply)
                 + image_id    = "fd8ciuqfa001h8s9sa7i"
                 + name        = (known after apply)
                 + size        = 20
                 + snapshot_id = (known after apply)
                 + type        = "network-hdd"
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
   
         + placement_policy {
             + placement_group_id = (known after apply)
           }
   
         + resources {
             + core_fraction = 100
             + cores         = 2
             + memory        = 2
           }
   
         + scheduling_policy {
             + preemptible = (known after apply)
           }
       }
   
     # yandex_compute_instance.for-each_vm["vm03"] will be created
     + resource "yandex_compute_instance" "for-each_vm" {
         + created_at                = (known after apply)
         + folder_id                 = (known after apply)
         + fqdn                      = (known after apply)
         + hostname                  = (known after apply)
         + id                        = (known after apply)
         + metadata                  = {
             + "ssh-keys" = <<-EOT
                   ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC82H6GGNVhzPlQbOvXGbmjzneF3YufolwYqNj2Z9TMED0erNTQUO2X2J0zFEBtaYNn9/aLsU8OhBOX4tU31aJNLuf9TW7oewgY23aN2LGUUX8giHZdjqD4yfjmwyojnbFsD2gj7slSF1bjbieAZ7LYXrpg62082FNJrFb5BM1yMFItrSerYNynkJm//JxyWg4XkvaUz6z+3bzxcJos+goTHzNlrmzpKJ4Upywf4r2nACALjhUnbqNdA1Y/0P+dP7E7ZwyWmp55pdJTbB3//rES6+nO45Uj1YocxM6KNd5g1L0TGh8TH3lCUnSIjY2uarh9wRVfmX610iHShbvLJrQCvszaUQ2i9zIqNeX/nkMFHLVMGV36Nq0m2kFZAScQjUtK/OScxuL4lF5aDk2T7NpRpjGdJhha9I9wOpN9FQ/k/aapDZCYUROh8F1pptXG0bQUoiwY6fTxQ8p+dZvlYTmFQMPVPdhVj74X8l2AcQCwxYlZN+pR2fsCIoIQ7cPtFzk= vagrant@vagrant
               EOT
           }
         + name                      = "for-each-vm03"
         + network_acceleration_type = "standard"
         + platform_id               = "standard-v1"
         + service_account_id        = (known after apply)
         + status                    = (known after apply)
         + zone                      = (known after apply)
   
         + boot_disk {
             + auto_delete = true
             + device_name = (known after apply)
             + disk_id     = (known after apply)
             + mode        = (known after apply)
   
             + initialize_params {
                 + description = (known after apply)
                 + image_id    = "fd8ciuqfa001h8s9sa7i"
                 + name        = (known after apply)
                 + size        = 20
                 + snapshot_id = (known after apply)
                 + type        = "network-hdd"
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
   
         + placement_policy {
             + placement_group_id = (known after apply)
           }
   
         + resources {
             + core_fraction = 100
             + cores         = 2
             + memory        = 2
           }
   
         + scheduling_policy {
             + preemptible = (known after apply)
           }
       }
   
     # module.vpc.yandex_vpc_network.this will be created
     + resource "yandex_vpc_network" "this" {
         + created_at                = (known after apply)
         + default_security_group_id = (known after apply)
         + description               = "managed by terraform prod network"
         + folder_id                 = (known after apply)
         + id                        = (known after apply)
         + name                      = "prod"
         + subnet_ids                = (known after apply)
       }
   
     # module.vpc.yandex_vpc_subnet.this["ru-central1-a"] will be created
     + resource "yandex_vpc_subnet" "this" {
         + created_at     = (known after apply)
         + description    = "managed by terraform prod subnet for zone ru-central1-a"
         + folder_id      = (known after apply)
         + id             = (known after apply)
         + name           = "prod-ru-central1-a"
         + network_id     = (known after apply)
         + v4_cidr_blocks = [
             + "10.10.0.0/24",
           ]
         + v6_cidr_blocks = (known after apply)
         + zone           = "ru-central1-a"
       }
   
   Plan: 7 to add, 0 to change, 0 to destroy.
   
   ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   
   Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
   ```
   </Details>

* [Ссылка на конфигурацию](terraform_config)
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
