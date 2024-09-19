#!/usr/bin/env bash

USAGE=$(cat << EOF
Usage: linecut [options...]

  Utility that repeats stdin, but cuts of lines which are longer that a
  specified maximum, counted in characters.
  
  NOTE: As three ellipses '...' are added to the end of cut lines, the actually
        printed maximum length is <length> + 3.

Options:
  -h, --help                     Show this help message.
  -l <length>, --length <length> The maximum length that will be repeated. Defaults to 80.
EOF
)

LENGTH=80

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -l|--length)
            LENGTH="$2"
            shift # past argument
            shift # past value
            ;;
        *)
        echo "$USAGE"
        exit 1
        ;;
    esac
done

while IFS= read -r line; do
    current_len=$(printf "$line" | wc --chars)
    if (( current_len > LENGTH )); then
        echo "${line:0:$LENGTH}..."
    else
        echo "$line"
    fi

done
