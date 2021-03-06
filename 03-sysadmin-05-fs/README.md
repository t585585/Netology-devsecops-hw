# Домашнее задание к занятию "3.5. Файловые системы"

Q1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

A1. Узнал.

Q2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

A2. Не могут. Жесткая ссылка и файл, для которого она создавалась, имеют одинаковые inode. Поэтому жесткая ссылка имеет те же права доступа, владельца и время последней модификации, что и целевой файл. Различаются только имена файлов. Фактически жесткая ссылка это еще одно имя для файла.

Q3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

A3. Сделано.

Q4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

A4. Сделано.

````
root@vagrant:~# fdisk /dev/sdb -l
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00f6d624

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux
````

Q5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

A5. Сделано.

````
sfdisk -d /dev/sdb | sfdisk /dev/sdc
````

````
root@vagrant:~# fdisk /dev/sdc -l
Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00f6d624

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux
````

Q6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

A6. Сделано.

````
root@vagrant:~# mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
````

Q7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

A7. Сделано.

````
root@vagrant:~# mdadm --create --verbose /dev/md2 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md2 started.
````

Q8. Создайте 2 независимых PV на получившихся md-устройствах.

A8. Сделано.

````
root@vagrant:~# pvcreate /dev/md1 /dev/md2
  Physical volume "/dev/md1" successfully created.
  Physical volume "/dev/md2" successfully created.
````

Q9. Создайте общую volume-group на этих двух PV.

A9. Сделано.

````
root@vagrant:~# vgcreate VG /dev/md1 /dev/md2
  Volume group "VG" successfully created
````

Q10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

A10. Сделано.

````
root@vagrant:~# lvcreate -L100 -nlv100 VG /dev/md2
  Logical volume "lv100" created.
````

Q11. Создайте `mkfs.ext4` ФС на получившемся LV.

A11. Сделано.

````
root@vagrant:~# mkfs.ext4 /dev/mapper/VG-lv100
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
````

Q12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

A12. Сделано.

````
root@vagrant:~# mkdir /tmp/new
root@vagrant:~# mount -t ext4 /dev/mapper/VG-lv100 /tmp/new
root@vagrant:~# mount
...
/dev/mapper/VG-lv100 on /tmp/new type ext4 (rw,relatime,stripe=256)
````

Q13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

A13. Сделано.

````
root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2021-12-03 19:00:37--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22580844 (22M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                       100%[============================================================================>]  21.53M  5.38MB/s    in 7.5s

2021-12-03 19:00:44 (2.88 MB/s) - ‘/tmp/new/test.gz’ saved [22580844/22580844]
````

Q14. Прикрепите вывод `lsblk`.

A14. Сделано.

````
root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md1                9:1    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md2                9:2    0 1018M  0 raid0
    └─VG-lv100       253:2    0  100M  0 lvm   /tmp/new
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md1                9:1    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md2                9:2    0 1018M  0 raid0
    └─VG-lv100       253:2    0  100M  0 lvm   /tmp/new
````

Q15. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

A15. Сделано.

````
root@vagrant:~# gzip -t /tmp/new/test.gz | echo $?
0
````

Q16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

A16. Сделано.

````
root@vagrant:~# pvmove /dev/md2 /dev/md1
  /dev/md2: Moved: 12.00%
  /dev/md2: Moved: 100.00%
````

Q17. Сделайте `--fail` на устройство в вашем RAID1 md.

A17. Сделано.

````
root@vagrant:~# mdadm /dev/md1 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md1
````

Q18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

A18. Сделано.

````
root@vagrant:~# dmesg -T | grep raid
...
[Fri Dec  3 19:06:55 2021] md/raid1:md1: Disk failure on sdb1, disabling device.
                           md/raid1:md1: Operation continuing on 1 devices.
````

Q19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

A19. Сделано.

````
root@vagrant:~# gzip -t /tmp/new/test.gz | echo $?
0
````

Q20. Погасите тестовый хост, `vagrant destroy`.

A20. Сделано.