# HyPhy filter (see below for explanation)
if ."analysis"."info" | contains("aBSREL") then
    # Print Header
    [
        "Testname",
        "Filename",
        "Sequences",
        "Sites",
        "Partition count",
        "Positive test results",
        "Test category",
        "Spp/Node",
        "Num rate classes",
        "Uncorrected P-Value",
        "Corrected P-Value",
        "Tested",
        "Rate category",
        "Omega",
        "Proportion"
    ],
    # Print table values
    ( ."analysis" |
        [
            ."info"                                # Name of HyPhy test
        ]
    ) +                          
    ( ."input" |
        [
            ."file name",                          # Name of file
            ."number of sequences",                # Number of sequences
            ."number of sites",                    # Number of sites
            ."partition count"                     # Partition count
        ]
    ) +                         
    ( ."test results" |
        [
            ."positive test results",               # Number of significant results
            ."tested"                               # Number of tests performed
        ]
    ) +
    ( ( ."branch attributes"."0" | keys[] ) as $k |
        [
            $k,                                                  # Spp/Node
            ."branch attributes"."0"[$k]."Rate classes",         # Number of rate classes
            ."branch attributes"."0"[$k]."Uncorrected P-value",  # Uncorrected P-value
            ."branch attributes"."0"[$k]."Corrected P-value",    # Corrected P-value
            ."tested"."0"[$k]                                    # Tested
        ] +
            ( ."branch attributes"."0"[$k]."Rate Distributions" |
                keys[] as $j |
                [
                    $j,                            # Rate category
                    .[$j][0],                      # Omega
                    .[$j][1]                       # Proportion
                ]
            )
    ) 
   |
    
    # Convert JSON to TSV
    @tsv
elif ."analysis"."info" | contains("FEL") then
    empty
elif ."branch attributes"."attributes" | contains("RELAX") then
        # Print Header
    [
        "Testname",
        "Filename",
        "Sequences",
        "Sites",
        "LRT",
        "P-value",
        "K",
        "Spp/Node",
        "Branch length",
        "Branch K",
        "Test category"
    ],
    # Print table values
    ( 
        [
         "RELAX"                                   # Name of HyPhy test
        ]
    ) +                          
    ( ."input" |
        [
            ."file name",                          # Name of file
            ."number of sequences",                # Number of sequences
            ."number of sites"                     # Number of sites
        ]
    ) +                         
    ( ."test results" |
        [
            ."LRT",                                            # Results of LRT
            ."p-value",                                        # Overall P-value
            ."relaxation or intensification parameter"         # Overall intensification (K) parameter
        ]
    ) +
    ( ( ."branch attributes"."0" | keys[] ) as $k |
        [
            $k,                                                  # Spp/Node
            ."branch attributes"."0"[$k]."Nucleotide GTR",         # Branch length 
            ."branch attributes"."0"[$k]."k (general descriptive)",  # K of branch
            ."tested"."0"[$k]                                    # Test category (Test or Reference)
        ] 
    ) 
   |   
    # Convert JSON to TSV
    @tsv
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

