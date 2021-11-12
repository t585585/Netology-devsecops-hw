# Домашнее задание к занятию «2.2. Основы Git»

## Задание №1 – Знакомимся с gitlab и bitbucket 

результат команды `git remote -v` следующий:
```
bitbucket       https://t585585@bitbucket.org/t585585/netology-devsecops-hw.git (fetch)
bitbucket       https://t585585@bitbucket.org/t585585/netology-devsecops-hw.git (push)
gitlab  https://gitlab.com/t585585/Netology-devsecops-hw.git (fetch)
gitlab  https://gitlab.com/t585585/Netology-devsecops-hw.git (push)
origin  https://github.com/t585585/Netology-devsecops-hw.git (fetch)
origin  https://github.com/t585585/Netology-devsecops-hw.git (push)
```

добавим репозитарии по `ssh`...

... сгенерим ключи, "покурим" маны )

результат команды `git remote -v` следующий:
```
bitbucket       https://t585585@bitbucket.org/t585585/netology-devsecops-hw.git (fetch)
bitbucket       https://t585585@bitbucket.org/t585585/netology-devsecops-hw.git (push)
bitbucket-ssh   git@bitbucket.org:t585585/netology-devsecops-hw.git (fetch)
bitbucket-ssh   git@bitbucket.org:t585585/netology-devsecops-hw.git (push)
gitlab  https://gitlab.com/t585585/Netology-devsecops-hw.git (fetch)
gitlab  https://gitlab.com/t585585/Netology-devsecops-hw.git (push)
gitlab-ssh      git@gitlab.com:t585585/Netology-devsecops-hw.git (fetch)
gitlab-ssh      git@gitlab.com:t585585/Netology-devsecops-hw.git (push)
origin  https://github.com/t585585/Netology-devsecops-hw.git (fetch)
origin  https://github.com/t585585/Netology-devsecops-hw.git (push)
origin-ssh      git@github.com:t585585/Netology-devsecops-hw.git (fetch)
origin-ssh      git@github.com:t585585/Netology-devsecops-hw.git (push)
```
