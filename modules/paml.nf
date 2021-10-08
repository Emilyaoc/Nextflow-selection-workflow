params.options = [:]

process PAML {

    conda (params.enable_conda ? "bioconda::paml:4.9" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/paml:4.9--h779adbc_6"
    } else {
        container "quay.io/biocontainers/paml:4.9--h779adbc_6"
    }

    input:
    path alignment

    output:
    path "*", emit: paml

    script:
    """
    cat << END_CTL > model.ctl
    END_CTL
    """

}
