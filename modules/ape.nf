process APE {
    // directives:
    tag "${species_tree.baseName}"
    conda "conda-forge::r-base=4.4.2 conda-forge::r-ape=5.8_1"
    container "community.wave.seqera.io/library/r-ape_r-base:0a895873e5f4568a"

    input:
    tuple val(id), path(headers), path(species_tree)

    script:
    """
    #! /usr/bin/env Rscript

    library(ape)

    seqnames=read.delim("$headers", header=FALSE)
    tree=ape::read.tree("$species_tree") # reads tree file into R as object
    trimmed_tree=ape::keep.tip(tree, seqnames\$V1) # trims tree to only include species in alignment
    ape::write.tree(trimmed_tree,"${species_tree.baseName}.trimmed.tree") # save tree to file
    """

    output:
    tuple val(id), path("*.trimmed.tree"), emit: tree
}
