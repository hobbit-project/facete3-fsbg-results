#!/bin/bash

set -eux

. ~/benchmark_config.sh

query_template='select ?p (count(distinct ?s) as ?cnt) where { { select * where {  ?s ?p ?o } limit %d } } group by ?p'
limits=(1000000 2000000 3000000 4000000)

id=1
for system in "${systems[@]}"; do
    echo $system >&2
    for limit in "${limits[@]}"; do

	query=$(printf "$query_template" "$limit" | tr ' ' +)
	endpoint=$(eval "echo \"\$endpoint_${system}\"")

	starttime=$(date +%s)

	curl "$endpoint" -d "query=$query" >/dev/null

	endtime=$(date +%s)

	duration=$((endtime-starttime))

	cat <<EOF
<http://example.org/count-$id>
	<http://www.example.org/duration>
		"$duration" ;
	<http://www.example.org/system>
		"$system" ;
	<http://www.example.org/limit>
		"$limit"^^<http://www.w3.org/2001/XMLSchema#long> ;
	<http://www.example.org/queryString>
		"$query" ;
.
EOF
	id=$((id+1))
    done
    
done
