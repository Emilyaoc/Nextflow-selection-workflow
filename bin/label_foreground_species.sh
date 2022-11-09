grep "\S" $2 | \
    while read spp; do
        sed -i '.bak' "s/$spp:/$spp{Foreground}:/" $1 
    done 