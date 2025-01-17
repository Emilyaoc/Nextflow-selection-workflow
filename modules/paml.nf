process PAML {
    // directives:
    tag "${alignment.simpleName}"
    conda "bioconda::paml:4.9"
    container "${workflow.containerEngine in [ 'singularity', 'apptainer' ] ?
        "https://depot.galaxyproject.org/singularity/paml:4.9--h779adbc_6" :
        "quay.io/biocontainers/paml:4.9--h779adbc_6" }"

    input:
    path alignment

    script:
    """
    cat << END_CTL > model.ctl
    END_CTL
    """

    output:
    path "*", emit: paml
}
