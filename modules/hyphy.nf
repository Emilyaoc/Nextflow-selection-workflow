params.options = [:]

process HYPHY {

    tag "${fasta.simpleName}"

    conda (params.enable_conda ? "bioconda::hyphy:2.5.31" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/hyphy:2.5.31--h48c199c_0"
    } else {
        container "quay.io/biocontainers/hyphy:2.5.31--h48c199c_0"
    }

    input:
    tuple val(id), path(fasta), path(tree)
    val test

    output:
    path "*.json", emit: json

    script:
    def args = task.ext.args ?: ''
    """
    hyphy $args $test --alignment $fasta --tree $tree
    """

}
