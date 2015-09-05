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
    echo "  -v, --verbose"
    echo "  -V, --version"
    echo "  -h, --help"
    exit "$exit_status"
}

echo_verbose () {
    if [ $verbose -gt 0 ]; then
        echo "$@"
    fi
}

input_file=""
output_file=""
verbose=0

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
        -v|--verbose)
            verbose=1
            shift
            ;;
        -V|--version)
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
if [ -z "$output_file" ]; then
    dir=$(dirname "$input_file")
    name=$(basename "$input_file" ".vcf")
    output_file="$dir/$name.new.vcf"
fi

echo "in:  $input_file"
echo "out: $output_file"
echo_verbose "verbose mode on"
