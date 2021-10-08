params.options = [:]

process PRANK {

    conda (params.enable_conda ? "bioconda::prank:v.150803" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/prank:v.150803--0"
    } else {
        container "quay.io/biocontainers/prank:v.150803--0"
    }

    input:
    tuple path( sequences ), path( tree )

    output:
    tuple path( "*.best.fas" ), path( tree ), emit: hyphy_alignment
    path "*.phy"                            , emit: paml_alignment

    script:
    def prefix = sequences.baseName
    """
    prank -d=$sequences \\
        -t=$tree \\
        -o=${prefix} \\
        -codon -once -F
    prank -convert -f=paml -keep \\
        -d=${prefix}.best.fas \\
        -o=${prefix}
    """

}
