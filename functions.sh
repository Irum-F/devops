#!/bin/bash
hello() {
    echo "Hello world!"
}
greet(){
    local name="$1"
    echo "Hello, $name!"
}
print_args(){
    echo "Number of arguments: $#"
    echo "Script name: $0"
    echo "First argument: $1"
    echo "Second argument: $2"
    echo "All arguments: $@"
}
print_args "Alice" "Bob" "Charlie"