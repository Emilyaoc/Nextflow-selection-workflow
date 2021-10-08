# HyPhy filter (see below for explanation)
if ."analysis"."info" | contains("aBSREL") then
    # Print Header
    [
        "Filename",
        "Sequences",
        "Sites",
        "Partition count",
        "Spp/Node",
        "Num rate classes",
        "Uncorrected P-Value",
        "Corrected P-Value",
        "Rate category",
        "Omega",
        "Proportion"
    ],
    # Print table values
    ( ."input" |
        [
            ."file name",                          # Name of file
            ."number of sequences",                # Number of sequences
            ."number of sites",                    # Number of sites
            ."partition count"                     # Partition count
        ]
    ) +
    ( ."branch attributes"."0" |
        keys[] as $k |
        [
            $k,                                    # Spp/Node
            .[$k]."Rate classes",                  # Number of rate classes
            .[$k]."Uncorrected P-value",           # Uncorrected P-value
            .[$k]."Corrected P-value"              # Corrected P-value
        ] +
            ( .[$k]."Rate Distributions" |
                keys[] as $j |
                [
                    $j,                            # Rate category
                    .[$j][0],                      # Omega
                    .[$j][1]                       # Proportion
                ]
            )
    ) |
    # Convert JSON to TSV
    @tsv
elif ."analysis"."info" | contains("FEL") then
    empty
elif ."analysis"."info" | contains("BUSTED") then
    # Print Header
    [
        "Filename",
        "Sequences",
        "Sites",
        "Partition count",
        "Omega W1",
        "Proportion W1",
        "Omega W2",
        "Proportion W2",
        "Omega W3",
        "Proportion W3",
        "LRT",
        "P-Value"
    ],
    # Print table values
    ( ."input" |
        [
            ."file name",                          # Name of file
            ."number of sequences",                # Number of sequences
            ."number of sites",                    # Number of sites
            ."partition count"                     # Partition count
        ]
    ) +
    ( . "fits" . "Unconstrained model" . "Rate Distributions" . "Test" . "0" | 
        [
            ."omega",                          # omega w1
            ."proportion"                     # proportion w1
        ]
     ) +
    ( . "fits" . "Unconstrained model" . "Rate Distributions" . "Test" . "1" | 
        [
            ."omega",                          # omega w2
            ."proportion"                      # proportion w2
        ]
     ) +      
    ( . "fits" . "Unconstrained model" . "Rate Distributions" . "Test" . "2" | 
        [
            ."omega",                          # omega w3
            ."proportion"                     # proportion w3
        ]
     ) + 
    ( ."test results" |
        [
            ."LRT",                            # LRT 
            ."p-value"                        # P-value
        ]
     ) | @tsv 					# Convert JSON to TSV
    
else
    empty
end

## Desired output - Hyphy ABSREL
## Gene Name, Spp/Node (e.g. Lanius c), Seqs, Sites, Partitions, Rate classes, Rate category, Omega, Proportion, Uncorrected P, corrected P.
## JQ filter to extract the required elements:
## Gene name - not present in file, but in file name:
# ."input"."file name"
## Spp/Node:
# ."branch attributes"."0" | keys
## Seqs
# ."input"."number of sequences"
## Sites
# ."input"."number of sites"
## Partitions
# ."input"."partition count"
## Rate classes
# ."branch attributes"."0" | keys[] as $i | .[$i]."Rate classes"
## Rate category
# ."branch attributes"."0" | keys[] as $j | ( .[$j]."Rate Distributions" | keys[] )
## Omega + Proportion
# ."branch attributes"."0" | keys[] as $k |  ( .[$k]."Rate Distributions" | keys[] as $j | [ $j, .[$j][0], .[$j][1] ] )

## JQ construct explanation ( https://jqplay.org/ for experimenting)
## Extract object at field
# ."name of field"
## Process object with filter
# ."field" | <new_filter>
# e.g. ."field_1" | ."field_X of field_1"
## "For loop"
# keys[] as $k
## Combinatoric "Addition" of arrays
#  e.g., [1] + ([3],[4])  ==> [1,3],[1,4]
#  e.g., ([1],[2]) + ([3],[4])   ==> [1,3],[2,3],[1,4],[2,4]

