# Домашнее задание к занятию «2.4. Инструменты Git»

Для выполнения заданий в этом разделе склонируем репозиторий с исходным кодом 
терраформа https://github.com/hashicorp/terraform 

В виде результата напишите текстом ответы на вопросы и каким образом эти ответы были получены. 

Q1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.

A1. `git show aefea -s`
```
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

    Update CHANGELOG.md

```

Q2. Какому тегу соответствует коммит `85024d3`?

A2. `git show 85024d3 -s --oneline`
```
85024d310 (tag: v0.12.23) v0.12.23
```

Q3. Сколько родителей у коммита `b8d720`? Напишите их хеши.

A3. `git show -s --format=%p b8d720`
```
56cd7859e 9ea88f22f
```
Q4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами  v0.12.23 и v0.12.24.

A4. `git log v0.12.23^..v0.12.24 --oneline
```
33ff1c03b v0.12.24
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release
85024d310 v0.12.23
```

Q5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит 
так `func providerSource(...)` (вместо троеточего перечислены аргументы).

A5. `git log -S 'func providerSource(' --pretty=format:"%H %s"`
```
8c928e83589d90a031f811fae52a81be7153e82f main: Consult local directories as potential mirrors of providers
```
Q6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.

A6. `git log -S 'globalPluginDirs' --pretty=format:"%H %s"`
```
35a058fb3ddfae9cfee0b3893822c9a95b920f4c main: configure credentials from the CLI config file
c0b17610965450a89598da491ce9b6b5cbd6393f prevent log output during init
8364383c359a6b738a436d1b7745ccdce178df47 Push plugin discovery down into command package
```

Q7. Кто автор функции `synchronizedWriters`? 

A7. `git log -S 'synchronizedWriters' --pretty=format:"%an %ad" --reverse --date=short`
```
Martin Atkins 2017-05-03
James Bardin 2020-10-21
James Bardin 2020-11-30
```
* первый в списке - Автор

