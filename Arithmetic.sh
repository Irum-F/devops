#!/bin/bash
arith(){
    local num1=$1
    local num2=$2
    echo "Addition: $((num1 + num2))"
    echo "Subtraction: $((num1 - num2))"
    echo "Multiplication: $((num1 * num2))"
    if [ $num2 -ne 0 ];
    then
        echo "Division: $((num1 / num2))"
    else
        echo "Division: Cannot divide by zero"
    fi
}

arith 10 5