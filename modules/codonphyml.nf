process CODONPHYML {

    container "ghcr.io/emilyaoc/codonphyml:1.0"

    input:
    path alignment

    output:
    path "*_codonphyml_stats.txt", emit: codonphyml_stats
    path "*_codonphyml_tree.txt",  emit: codonphyml_tree

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: alignment.baseName
    """
    codonphyml \\
        -i $alignment \\
        $args
    """

}
