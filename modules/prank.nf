params.options = [:]

process PRANK {

    conda (params.enable_conda ? "bioconda::prank:v.150803" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/prank:v.150803--0"
    } else {
        container "quay.io/biocontainers/prank:v.150803--0"
    }

    input:
    path( sequences )
    path( tree )

    output:
    path "*.best.fas", emit: fasta_alignment
    path "*.phy"     , emit: paml_alignment

    script:
    def prefix = sequences.baseName
    def args   = task.ext.args  ?: ''
    def args2  = task.ext.args2 ?: ''
    """
    prank -d=$sequences \\
        -t=$tree \\
        -o=${prefix} \\
        $args
    prank $args2 \\
        -d=${prefix}.best.fas \\
        -o=${prefix}
    """

}
