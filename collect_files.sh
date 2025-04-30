#!/bin/bash

max_depth=-1
input="$1"
output="$2"
mkdir -p "$output"

copy() {
    local base_name="$(basename "$1")" # без путя
    local name="${base_name%.*}" # до точки
    local ext="${base_name##*.}" # после точки
    local counter=1
    local new="$base_name"
    while [ -e "$2/$new" ]; do
        if [ "$ext" = "$base_name" ]; then
            new="${name}_${counter}" #без расширения
        else
            new="${name}_${counter}.${ext}"
        fi
        counter=$((counter + 1))
    done
    cp "$1" "$2/$new"
}

funct() {
    local depth="$2"
    for f in "$1"/*; do
        if [ -f "$f" ]; then
            copy "$f" "$output"
        elif [ -d "$f" ]; then
            if [ "$max_depth" -eq -1 ] || [ "$depth" -lt "$max_depth" ]; then
                funct "$f" $((depth + 1))
            fi
        fi
    done
}

funct "$input" 0
