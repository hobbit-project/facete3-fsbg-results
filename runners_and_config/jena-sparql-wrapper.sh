#!/bin/bash

set -eux

declare -a xargs=()
declare -a data=()
declare -a query=()
declare -a fin=()

while [ $# -gt 0 ]; do
    case "$1" in
	-*)
	    xargs+=("$1")
	    shift
	    ;;
	*)
	    data+=("$1")
	    shift
	    ;;
    esac
done

if [ "${#xargs[@]}" -gt 0 ]; then
    fin+=("${xargs[@]}")
fi

if [ "${#data[@]}" -gt 0 ]; then
    query=("--query=${data[-1]}")
    unset data[-1]
fi

for i in "${!data[@]}"; do
    fin+=("--data=${data[$i]}")
done

if [ "${#query[@]}" -gt 0 ]; then
    fin+=("${query[@]}")
fi

set --
if [ "${#fin[@]}" -gt 0 ]; then
    set -- "${fin[@]}"
fi

exec sparql "$@"

