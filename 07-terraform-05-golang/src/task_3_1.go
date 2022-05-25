package main

import "fmt"

func main() {
	fmt.Print("Введите количество метров: ")
	var input float64
	fmt.Scanf("%f", &input)
	output := input / 0.3048
	fmt.Print(input, " метр(-а,-ов) - это ", output, " фут\n" )
}
