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
    tuple val(metadata.test), val(metadata.setting_id), path("*.tsv"), emit: tsv
}

// Native process to collect tsv files
process JQ_COLLECT {
    //directives:
    tag "${test}-${setting_id}"
    // native processes run locally and don't use package managers
    executor 'local'

    input:
    tuple val(test), val(setting_id), val(tsvs)

    exec:
    def outfile = file(task.workDir.resolve("${test}-${setting_id}.allgenes.tsv"))
    outfile.text = tsvs.head().splitText( limit: 1, keepHeader: false ).join() // Note: in Nextflow 24.10.4 keepHeader boolean is inverted.
    tsvs.each { tsv_file ->
        outfile.append( tsv_file.splitText( keepHeader: true ).join() ) // Note: Same issue. keepHeader value needs to be inverted
    }

    output:
    path "*.allgenes.tsv"
}
