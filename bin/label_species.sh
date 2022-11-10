#! /usr/bin/env bash

# $1: newick format species tree
# $2: two column format species and their labels
grep "\S" $2 | \
    while read spp lbl; do
        sed -i '.bak' "s/$spp:/$spp{$lbl}:/" $1 
    done 