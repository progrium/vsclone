#!/usr/bin/env bash

extract_script() {
    local filename="$1"
    
    # Check if file exists
    if [[ ! -f "$filename" ]]; then
        echo "Error: File '$filename' not found" >&2
        return 1
    fi
    
    # Extract content between <script> and </script>, preserving all whitespace between tags
    awk '
/<script>/,/<\/script>/ {
    line = $0
    if (!in_script) {
        sub(/^.*<script>/, "", line)
        in_script = 1
    }
    sub(/<\/script>.*$/, "", line)
    print line
}
' "$filename" | awk 'NR > 1 { printf "\n" } { printf "%s", $0 }'
}

extract_script $1 > checksum-debug.txt

echo "sha256-$(extract_script $1 | openssl dgst -sha256 -binary | openssl base64 -A)"