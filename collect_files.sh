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
    local name="$base_name"
    while [ -e "$fin/$name" ]; do
        if [ "$ext" = "$base_name" ]; then
            name="${name}_${counter}" #без расширения
        else
            name="${name}_${counter}.${ext}"
        fi
        counter=$((counter + 1))
    done
    cp "$1" "$fin/$name"
}



copy_dir() {
    local cur_dir="$1"
    local new_dir="$2"
    local base_name="$(basename "$new_dir")"
    local counter=1
    local name="$base_name"
    while [ -e "$cur_dir/$name" ]; do
        name="${base_name}_${counter}"
        counter=$((counter + 1))
    done
    mkdir "$cur_dir/$name"
    echo "$cur_dir/$name"
}

funct() {
    local cur_input="$1"
    local depth="$2"
    local cur_output="$3"
    local last="$4"
    local very_last="$5"
    for f in "$cur_input"/*; do
        if [ -f "$f" ]; then
            copy_f "$f" "$cur_output"
        elif [ -d "$f" ]; then
            if [ "$max_depth" -eq -1 ] || [ "$depth" -lt "$((max_depth-0))" ]; then
                new_path="$(copy_dir "$cur_output" "$f")"
                funct "$f" $((depth + 1)) "$new_path" "$cur_output" "$last"
            else 
                new_path="$(copy_dir "$very_last" "$cur_output")"
                new_path="$(copy_dir "$new_path" "$f")"
                funct "$f" $((depth)) "$new_path" "$cur_output" "$very_last"
            fi
        fi
    done
}

funct "$input" 1 "$output" "$output" "$output"
