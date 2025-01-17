process APE {
    // directives:
    tag "${species_tree.baseName}"
    conda "bioconda::hyphy:2.5.65"
    container "${workflow.containerEngine in [ 'singularity', 'apptainer' ] ?
        "https://depot.galaxyproject.org/singularity/hyphy:2.5.65--he91c24d_0" :
        "quay.io/biocontainers/hyphy:2.5.65--he91c24d_0" }"

    input:
    tuple val(id), path(species_tree)

    script:
    """
    #! /usr/bin/env Rscript

    library(ape)
    """

    output:
    tuple val(id), path("trimmed"), emit: trimmed_species_tree
}