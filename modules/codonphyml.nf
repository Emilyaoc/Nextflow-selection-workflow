process CODONPHYML {

    tag "${fa_alignment.simpleName}"

    container "ghcr.io/emilyaoc/codonphyml:1.0"

    input:
    tuple val(id), path(fa_alignment)
    path(foreground_species)

    output:
    tuple val(id), path("*_codonphyml_stats.txt"), emit: codonphyml_stats
    tuple val(id), path("*_codonphyml_tree.txt"),  emit: codonphyml_tree

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: fa_alignment.baseName
    """
    codonphyml \\
        -i $fa_alignment \\
        $args
    """

}
