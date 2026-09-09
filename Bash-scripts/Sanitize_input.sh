#!/bin/bash
sanitize_input() {
    local input=$1
    local sanitized_input=${input//[^a-zA-Z0-9]/}
    echo "$sanitized_input"
}

echo "Enter a username:"
read user_input
sanitized_username=$(sanitize_input "$user_input")
echo "Sanitized username: $sanitized_username"