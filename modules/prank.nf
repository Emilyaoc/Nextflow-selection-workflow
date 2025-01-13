params.options = [:]

process PRANK {

    tag "${sequences.simpleName}"

    conda (params.enable_conda ? "bioconda::prank:v.170427" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/prank:170427--h9948957_1"
    } else {
        container "quay.io/biocontainers/prank:170427--h9948957_1"
    }

    input:
    path(sequences)
    path(tree)

    output:
    tuple val(prefix), path("*.best.fas"), emit: fasta_alignment
    tuple val(prefix), path("*.phy")     , emit: paml_alignment

    script:
    prefix     = sequences.baseName
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
