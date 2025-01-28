process PRANK {
    // directives:
    tag "${sequences.simpleName}"
    conda "bioconda::prank:v.170427"
    container "${workflow.containerEngine in [ 'singularity', 'apptainer' ] ?
        "https://depot.galaxyproject.org/singularity/prank:170427--h9948957_1" :
        "quay.io/biocontainers/prank:170427--h9948957_1" }"

    input:
    path(sequences)
    path(tree)

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
    grep "^>" ${prefix}.best.fas | cut -c2- > ${prefix}.headers.txt
    """

    output:
    tuple val(prefix), path("*.best.fas"),    emit: fasta_alignment
    tuple val(prefix), path("*.headers.txt"), emit: fasta_headers
    tuple val(prefix), path("*.phy"),         emit: paml_alignment
}
