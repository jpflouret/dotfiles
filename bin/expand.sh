#!/bin/sh

expand_file() {
    if [ -w "$1" ]; then
        echo "$1"
        cp "$1" "$1~"
        expand --tabs=4 "$1~" > "$1"
        rm "$1~"
    else
        echo "Unable to write file $1"
    fi
}

while (($#)); do
    expand_file $1
    shift
done
