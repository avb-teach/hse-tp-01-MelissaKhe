#!/bin/bash

max_depth=${4:--1}
input="$1"
output="$2"
mkdir -p "$output"


copy_f() {
    local fin="$2"
    local base_name="$(basename "$1")" # без путя
    local name="${base_name%.*}" # до точки
    local ext="${base_name##*.}" # после точки
    local counter=1
    local new="$base_name"
    while [ -e "$fin/$new" ]; do
        if [ "$ext" = "$base_name" ]; then
            new="${name}_${counter}" #без расширения
        else
            new="${name}_${counter}.${ext}"
        fi
        counter=$((counter + 1))
    done
    cp "$1" "$fin/$new"
}



copy_dir() {
    local path_anc="$1"
    local path_current_dir="$2"
    local base_name="$(basename "$path_current_dir")"
    local counter=1
    local new="$base_name"
    while [ -e "$path_anc/$new" ]; do
        new="${base_name}_${counter}"
        counter=$((counter + 1))
    done
    mkdir "$path_anc/$new"
    echo "$path_anc/$new"
}

funct() {
    local path_input="$1"
    local depth="$2"
    local path_anc_output="$3"
    for f in "$path_input"/*; do
        if [ -f "$f" ]; then
            copy_f "$f" "$path_anc_output"
        elif [ -d "$f" ]; then
            if [ "$max_depth" -eq -1 ] || [ "$depth" -lt "$max_depth" ]; then
                funct "$f" $((depth + 1)) "$(copy_dir "$path_anc_output" "$f")"
            elif [ "$depth" -eq "$max_depth" ]; then
                ssss="$(copy_dir "$path_anc_output" "$f")"
                funct "$f" $depth "$(copy_dir "$ssss" "$f")" 
            fi
        fi
    done
}

funct "$input" 1 "$output"
