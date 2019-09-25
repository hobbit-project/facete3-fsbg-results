#!/bin/bash

set -eux

if [ ! -f claus_experiment/"$(basename "$1")" ]; then
    echo benchmark not found
    exit 1
fi


./jena-sparql-wrapper.sh --results=csv benchmark-result-"$(basename "$1")"-*.ttl claus_experiment/"$(basename "$1")" eval-result.sparql > time-"$(basename "$1")".csv
perl time_to_tab.pl time-"$(basename "$1")".csv > time2-"$(basename "$1")".csv
perl time_to_tab2.pl time-"$(basename "$1")".csv > latexeval-"$(basename "$1")".tex
