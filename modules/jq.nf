process JQ {
    // directives:
    tag "${json.simpleName}"
    conda "conda-forge::jq:1.6" : null
    container "${workflow.containerEngine in [ 'singularity', 'apptainer' ] ?
        "https://depot.galaxyproject.org/singularity/jq:1.6" :
        "quay.io/biocontainers/jq:1.6" }"

    input:
    tuple val(metadata), path(json)
    path jq_filter

    script:
    def args = task.ext.args ?: ''
    """
    jq $args \\
        -f ${jq_filter} \\
        $json > ${json.baseName}.tsv
    """

    output:
    path "*.tsv", emit: tsv
}
