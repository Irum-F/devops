#!/bin/bash
read -p "Enter the filename to check: " filename
if [ -e "$filename" ]; then
    echo "'$filename' exists."

    # Check if readable
    if [ -r "$filename" ]; then
        echo "  - Readable: Yes"
    else
        echo "  - Readable: No"
    fi

    # Check if writable
    if [ -w "$filename" ]; then
        echo "  - Writable: Yes"
    else
        echo "  - Writable: No"
    fi

    # Check if executable
    if [ -x "$filename" ]; then
        echo "  - Executable: Yes"
    else
        echo "  - Executable: No"
    fi
else
    echo "'$filename' does not exist."
fi