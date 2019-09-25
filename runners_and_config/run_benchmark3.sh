#!/bin/bash

set -eux

. ~/benchmark_config3.sh

benchmark_ttl=~/claus_experiment/zdb_lds_20190305_benchmark_v1.ttl
benchmark_sparql=~/faceted-browsing-benchmark/faceted-browsing-benchmark-parent/faceted-browsing-benchmark-v2-parent/benchmarks/test/run-benchmark2.sparql

for system in "${systems[@]}"; do
    echo $system >&2

    SYSTEM=$system REMOTE=$(eval "echo \"\$endpoint_${system}\"") \
	  sparql-integrate "$benchmark_ttl" "$benchmark_sparql" \
	  > "benchmark-result-$(basename "$benchmark_ttl")-${system}.ttl"

done
