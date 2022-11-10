grep "\S" $2 | \
    while read spp lbl; do
        sed -i '.bak' "s/$spp:/$spp{$lbl}:/" $1 
    done 