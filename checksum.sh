#!/bin/bash

calculate_md5sum() {
    local file_path="$1"
    md5sum "$file_path"
}

calculate_sha256sum() {
    local file_path="$1"
    sha256sum "$file_path"
}

compare_checksums() {
    local checksum1="$1"
    local checksum2="$2"
    if [ "$checksum1" == "$checksum2" ]; then
        echo "Checksums match."
    else
        echo "Checksums do not match."
    fi
}

compare_checksums "123" "123"
    