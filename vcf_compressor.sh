#!/bin/bash
## Copyright (c) 2015 Rodolphe Breard
## 
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

set -euo pipefail
IFS=$'\n\t'

version () {
    echo "VCF Compressor 0.1.0-dev"
    exit 0
}

usage () {
    exit_status="${1:-1}"
    echo "Usage: vcf_compressor [OPTION]... VCF_FILE"
    echo ""
    echo "Options:"
    echo "  -o, --output"
    echo "  --version"
    echo "  -h, --help"
    exit "$exit_status"
}

compress_photo () {
    line="$1"

    prefix=$(echo "$line" | cut -d ":" -f1)
    picture=$(echo "$line" | cut -d ":" -f2 | base64 -d | convert "-" -quality 50 -resize "300x300>" "-" | base64 -w0)
    echo "$prefix:$picture"
}

process_line () {
    line="$1"

    echo "$line" | egrep "^PHOTO;" | grep ";ENCODING=b;" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        compress_photo "$line"
    else
        echo "$line"
    fi
}

input_file=""
output_file=""

while :; do
    test $# -gt 0 || break
    case "$1" in
        -o|--output)
            if [ -n "$2" ]; then
                output_file="$2"
                shift 2
                continue
            else
                usage
            fi
            ;;
        --version)
            version
            ;;
        -h|--help)
            usage 0
            ;;
        *)
            if [ -z "$input_file" ]; then
                input_file="$1"
                shift
                continue
            else
                usage
            fi
            ;;
    esac
done
test -z "$input_file" && usage
if [ ! -f "$input_file" ]; then
    echo "$input_file: file not found"
    exit 1
fi
if [ -z "$output_file" ]; then
    dir=$(dirname "$input_file")
    name=$(basename "$input_file" ".vcf")
    output_file="$dir/$name.new.vcf"
fi

echo -n > "$output_file"

while IFS='' read -r line || [[ -n "$line" ]]; do
    line=$(process_line "$line")
    echo "$line" >> "$output_file"
done < "$input_file"
