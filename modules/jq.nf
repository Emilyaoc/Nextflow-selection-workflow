params.options = [:]

process JQ {

    container = ''
    conda (params.enable_conda ? "conda-forge::jq:1.6" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/jq:1.6"
    } else {
        container "quay.io/biocontainers/jq:1.6"
    }

    input:
    path json
    path jq_filter

    output:
    path "*.tsv", emit: tsv

    script:
    """
    jq ${params.options.args} \\
        -f ${jq_filter} \\
        $json > ${json.baseName}.tsv
    """

}
