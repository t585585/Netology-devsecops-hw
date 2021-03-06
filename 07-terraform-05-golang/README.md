# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Ответ
```shell
vagrant@vagrant:~/hw75$ go version
go version go1.13.8 linux/amd64
```

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Ответ

_Ознакомился_

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```
 
1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код. 

## Ответ

Задача 1
- код:
```go
package main

import "fmt"

func main() {
    fmt.Print("Введите количество метров: ")
    var input float64
    fmt.Scanf("%f", &input)
    output := input / 0.3048
    fmt.Print(input, " метр(-а,-ов) - это ", output, " фут\n" )
}
```
- вывод:
```shell
vagrant@vagrant:~/hw75$ ./task_3_1
Введите количество метров: 0.3048
0.3048 метр(-а,-ов) - это 1 фут
```

Задача 2
- код
```go
package main
import "fmt"
func main() {
    x := []int{48,2, 96,86,3,68,57,82,63,70,37,34,83,27,19,97,9,17,1}
    current := 0
    fmt.Println ("Список значений : ", x)
    for i, value := range x {
        if (i == 0) {
            current = value
        } else {
            if (value < current) {
                current = value
            }
        }
    }
    fmt.Println("Минимальное число : ", current)
}
```
- вывод
```shell
vagrant@vagrant:~/hw75$ go run task_3_2.go
Список значений :  [48 2 96 86 3 68 57 82 63 70 37 34 83 27 19 97 9 17 1]
Минимальное число :  1
```
Задача 3
- код
```go
package main
import "fmt"
func main() {
    for i := 1; i <= 100; i++ {
        if i%3 == 0 {
            fmt.Print(i," ")
        }
    }
    fmt.Println("")
}
```
- вывод
```shell
vagrant@vagrant:~/hw75$ go run task_3_3.go
3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 72 75 78 81 84 87 90 93 96 99
```

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

