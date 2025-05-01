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
    echo "$name"
}

funct() {
    local cur_input="$1" #input/a/b/c
    local depth="$2"
    local rel_cur_output="$3" #/b/c
    local flag="0"
    local name 
    local new_path
    local second_out # вторая часть (еще до удаления первой) относительного выходного пути с / до /
    local after_second # с третьей части (еще до удаления первой) относительного выходного пути с / до /
    for f in "$cur_input"/*; do # f с полным путем
        if [ -f "$f" ]; then
            copy_f "$f" "$output$rel_cur_output"
        elif [ -d "$f" ]; then
            if [ "$max_depth" -eq -1 ] || [ "$depth" -lt "$((max_depth))" ]; then
                name="$(copy_dir "$output$rel_cur_output" "$f")"
                funct "$f" $((depth + 1)) "$rel_cur_output/$name"
            elif [ "$flag" -eq 0 ]; then
                echo "$f"
                echo "$rel_cur_output"

                second_out="${rel_cur_output#*/}"
                echo "second_out without /=$second_out"
                second_out="${second_out#*/}"
                echo "second_out without first=$second_out"
                if [[ "$second_out" == */* ]]; then
                    after_second="${second_out#*/}"
                    second_out="${second_out%%/*}"
                    new_path="/$(copy_dir "$output" "$second_out")/$after_second"
                else
                    after_second=""
                    second_out="${second_out%%/*}"
                    new_path="/$(copy_dir "$output" "$second_out")"
                fi
                echo "second_out=$second_out"
                echo "after_second=$after_second"
                echo "new_path=$new_path"
                flag="1"

                name="$(basename "$f")"
                mkdir -p "$output$new_path/$name"
                funct "$f" $((depth)) "$new_path/$name"
            else 
                name="$(basename "$f")"
                mkdir -p "$output$new_path/$name"
                funct "$f" $((depth)) "$new_path/$name"
            fi
        fi
    done
}

funct_level1() {
    local cur_input="$1"
    for f in "$cur_input"/*; do
        if [ -f "$f" ]; then
            copy_f "$f" "$output"
        elif [ -d "$f" ]; then
            funct_level1 "$f"
        fi
    done
}

funct_level2() {
    local cur_input="$1"
    local depth="$2"
    local cur_output="$3"
    local new_path
    for f in "$cur_input"/*; do
        if [ -f "$f" ]; then
            copy_f "$f" "$cur_output"
        elif [ -d "$f" ]; then
            if [ "$depth" -eq 1 ]; then
                cur_output="$output/$(copy_dir "$output" "$f")"
                funct_level2 "$f" $((depth + 1)) "$cur_output"
            else 
                cur_output="$output/$(copy_dir "$output" "$f")"
                funct_level2 "$f" $((depth)) "$cur_output"
            fi
        fi
    done
}

if [ "$max_depth" -eq 1 ]; then
    funct_level1 "$input"
elif [ "$max_depth" -eq 2 ]; then
    funct_level2 "$input" 1 "$output"
else
    funct "$input" 1 ""  
fi
