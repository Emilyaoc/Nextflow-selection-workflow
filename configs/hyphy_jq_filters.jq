# HyPhy filter (see below for explanation)
if any( (."branch attributes"."attributes" | keys[] ) ; contains("RELAX") ) then
    # Print Header
    [
        "Testname",
        "Filename",
        "Sequences",
        "Sites",
        "Null AICc",
        "Alternative AICc",
        "LRT",
        "P-value",
        "K",
        "Spp/Node",
        "Branch length",
        "Branch K",
        "Test category"
    ],
    # Print table values 
    [ "RELAX" ]                                    # Name of HyPhy test 
    +   
    ( 
        ."input" |
            [
                ."file name" | capture("(?<fname>[0-9a-zA-Z_.]+)$").fname  # Name of file
            ]
    ) +
    (
        ."input" |
            [
                ."number of sequences",                                                 # Number of sequences
                ."number of sites"                                                      # Number of sites
            ]
    ) +    
    (   ."fits"."RELAX null" |
        [
            ."AIC-c"                            # Null model AICc
        ]
    ) +        
    (   ."fits"."RELAX alternative" |
        [
            ."AIC-c"                            # Alternative model AICc
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
    ) |   
    # Convert JSON to TSV
    @tsv
elif ."analysis"."info" | contains("aBSREL") then
    # Print Header
    [
        "Testname",
        "SRV",
        "Multiple hits",
        "Filename",
        "Sequences",
        "Sites",
        "Partition count",
        "Full adaptive AICc",
        "Full adaptive LogL",
        "Baseline MG94xREV AICc",
        "Positive test results",
        "Tested",
        "Spp/Node",
        "Baseline MG94xREV",
        "Baseline MG94xREV omega ratio",
        "Branch length",
        "dN",
        "dS",
        "LRT",
        "Nucleotide GTR",
        "Num rate classes",
        "Uncorrected P-Value",
        "Corrected P-Value",
        "Test category",
        "Rate category",
        "Omega",
        "Proportion"
    ],
    # Print table values
    ( ."analysis" |
        [
            ."info" | capture("(?<test>[a-zA-Z]+)" ).test  # Name of HyPhy test
        ]
    ) +  
    (."analysis"."settings" |
        [
            ."srv"                                      # SRV
        ]
    ) + 
        (."analysis"."settings" |
        [
            ."multiple-hit"                         # Multiple hits
        ]

    ) +  
    (  ."input" |
            [
                ."file name" | capture("(?<fname>[0-9a-zA-Z_.]+)$").fname  # Name of file
            ]
    ) +                      
    ( ."input" |
        [
            ."number of sequences",                # Number of sequences
            ."number of sites",                    # Number of sites
            ."partition count"                     # Partition count
        ]
    ) + 
     ( ."fits"."Full adaptive model" |
        [
            ."AIC-c",                            # Full adaptive AICc
            ."Log Likelihood"                    # Full adaptive LogL
        ]
    ) +
    ( ."fits"."Baseline MG94xREV" |
        [
            ."AIC-c"                            # Baseline MG94xREV AICc

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
            ."branch attributes"."0"[$k]."Baseline MG94xREV",  # baseline branch length
            ."branch attributes"."0"[$k]."Baseline MG94xREV omega ratio",  # baseline omega
            ."branch attributes"."0"[$k]."Full adaptive model",  # branch length
            ."branch attributes"."0"[$k]."Full adaptive model (non-synonymous subs/site)", # dN
            ."branch attributes"."0"[$k]."Full adaptive model (synonymous subs/site)", # dS
            ."branch attributes"."0"[$k]."LRT", # result of LRT
            ."branch attributes"."0"[$k]."Nucleotide GTR", # output from GTR
            ."branch attributes"."0"[$k]."Rate classes",         # Number of rate classes
            ."branch attributes"."0"[$k]."Uncorrected P-value",  # Uncorrected P-value
            ."branch attributes"."0"[$k]."Corrected P-value",    # Corrected P-value
            ."tested"."0"[$k]                                    # Test categories (Test or Background)
        ] +
            ( ."branch attributes"."0"[$k]."Rate Distributions" |
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
elif ."analysis"."info" | contains("Contrast-FEL") then
    # Print Header
    [
        "Testname",
        "Filename",
        "Sequences",
        "Sites",
        "Site Number"
    ] + [ ."MLE"."headers"[][0] ],
    # Print table values
    ( ."analysis" |
        [
            ."info" | capture("(?<test>[a-zA-Z-]+)" ).test  # Name of HyPhy test
        ]
    ) + ( 
        ."input" |
            [
                ."file name" | capture("(?<fname>[0-9a-zA-Z_.]+)$").fname  # Name of file
            ]
    ) +
    (
        ."input" |
            [
                ."number of sequences",                                                 # Number of sequences
                ."number of sites"                                                      # Number of sites
            ]
    ) + 
    (  
        range( ."data partitions"."0"."coverage"[] | length ) as $idx | 
            [ ."data partitions"."0"."coverage"[][$idx] ]                # Site number
            + ."MLE"."content"."0"[$idx]                                 # Rate classes
    ) | @tsv 
    elif ."analysis"."info" | contains("MEME") then
    # Print Header
    [
        "Testname",
        "Filename",
        "Sequences",
        "Sites",
        "Condon_nr"
    ] + [ ."MLE"."headers"[][0] ],
    # Print table values
    ( ."analysis" |
        [
            ."info" | capture("(?<test>[a-zA-Z-]+)" ).test  # Name of HyPhy test
        ]
    ) + ( 
        ."input" |
            [
                ."file name" | capture("(?<fname>[0-9a-zA-Z_.]+)$").fname  # Name of file
            ]
    ) +
    (
        ."input" |
            [
                ."number of sequences",                                                 # Number of sequences
                ."number of sites"                                                      # Number of sites
            ]
    ) + 
    (  
        range( ."data partitions"."0"."coverage"[] | length ) as $idx | 
            [ ."data partitions"."0"."coverage"[][$idx] ]                # Site number
            + ."MLE"."content"."0"[$idx]                                 # Site results
    ) | @tsv 
elif ."analysis"."info" | contains("FEL") then
    empty
elif ."analysis"."info" | contains("BUSTED-PH") then
        # Print Header
    [
        "Testname",
        "Filename",
        "Sequences",
        "Sites",
        "Partition count",
        "Unconstrained AICc",
        "Unconstrained LogL",
        "Background Omega W1",
        "Background Proportion W1",
        "Background Omega W2",
        "Background Proportion W2",
        "Background Omega W3",
        "Background Proportion W3",
        "Test Omega W1",
        "Test Proportion W1",
        "Test Omega W2",
        "Test Proportion W2",
        "Test Omega W3",
        "Test Proportion W3",
        "Test LRT",
        "Test P-Value",
        "Background LRT",
        "Background P-Value",
        "Shared LRT",
        "Shared P-Value"
    ],
    # Print table values
    ( ."analysis" |
        [
            ."info" | capture("(?<test>[a-zA-Z]+)" ).test   # Name of HyPhy test
        ]
    ) +   
    ( ."input" |
        [
            ."file name" | capture("(?<fname>[0-9a-zA-Z_.]+)$").fname  # Name of file
        ]
    ) +
        ( ."input" |
        [
            ."number of sequences",                                     # Number of sequences
            ."number of sites",                                         # Number of sites
            ."partition count"                                           # Partition count
        ]
    ) +
    ( ."fits"."Unconstrained model" |
        [
            ."AIC-c",                            # Unconstrained model AICc
            ."Log Likelihood"                    # Unconstrained model LogL
        ]
    ) +
    ( ."fits"."Unconstrained model"."Rate Distributions"."Background". "0" | 
        [
            ."omega",                          # Background omega w1
            ."proportion"                      # proportion w1
        ]
    ) +
        ( ."fits"."Unconstrained model"."Rate Distributions"."Background". "1" | 
        [
            ."omega",                          # Background omega w2
            ."proportion"                      # Background proportion w2
        ]
    ) +
    ( ."fits"."Unconstrained model"."Rate Distributions"."Background". "2" | 
        [
            ."omega",                          # Background omega w3
            ."proportion"                      # Background proportion w3
        ]
    ) +
    ( ."fits"."Unconstrained model"."Rate Distributions"."Test". "0" | 
        [
            ."omega",                          # Test omega w1
            ."proportion"                      # Test proportion w1
        ]
    ) +
    ( ."fits"."Unconstrained model"."Rate Distributions"."Test". "1" | 
        [
            ."omega",                          # Test omega w2
            ."proportion"                      # Test proportion w2
        ]
    ) +
    ( ."fits"."Unconstrained model"."Rate Distributions"."Test". "2" | 
        [
            ."omega",                          # Test omega w3
            ."proportion"                      # Test proportion w3
        ]
    ) +
    ( ."test results" |
        [
            ."LRT",                            # Test LRT 
            ."p-value"                         # Test P-value
        ]
    ) +
    ( ."test results background" |
        [
            ."LRT",                            # Background LRT 
            ."p-value"                         # Background P-value
        ]
    ) +
    ( ."test results shared distributions" |
        [
            ."LRT",                            # Shared LRT 
            ."p-value"                         # Shared P-value
        ]
    )
    | @tsv 					               # Convert JSON to TSV
elif ."analysis"."info" | contains("BUSTED") then
    # Print Header
    [
        "Testname",
        "SRV",
        "Multiple hits",
        "Filename",
        "Sequences",
        "Sites",
        "Partition count",
        "Unconstrained model AICc",
        "Unconstrained model LogL",
        "Constrained model AICc",
        "Constrained model LogL",
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
    ( ."analysis" |
        [
            ."info" | capture("(?<test>[a-zA-Z]+)" ).test   # Name of HyPhy test
        ]
    ) +
     (."analysis"."settings" |
        [
            ."srv"                                      # SRV
        ]
    ) + 
        (."analysis"."settings" |
        [
            ."multiple-hit"                         # Multiple hits
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
    ( ."fits"."Unconstrained model" |
        [
            ."AIC-c",                            # Unconstrained model AICc
            ."Log Likelihood"                    # Unconstrained model LogL
        ]
    ) +
    ( ."fits"."Constrained model" |
        [
            ."AIC-c",                            # Constrained model AICc
            ."Log Likelihood"                    # Constrained model LogL

        ]
    ) +
    ( . "fits" . "Unconstrained model" . "Rate Distributions" . "Test" . "0" | 
        [
            ."omega",                          # omega w1
            ."proportion"                      # proportion w1
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
            ."proportion"                      # proportion w3
        ]
    ) + 
    ( ."test results" |
        [
            ."LRT",                            # LRT 
            ."p-value"                         # P-value
        ]
    ) | @tsv 					               # Convert JSON to TSV
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

