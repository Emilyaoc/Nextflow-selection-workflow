process CODONPHYML {

    tag "${fa_alignment.simpleName}"

    container "ghcr.io/emilyaoc/codonphyml:1.0"

    input:
    tuple val(id), path(fa_alignment)
    path(foreground_species)

    output:
    tuple val(id), path("*_codonphyml_stats.txt"),     emit: codonphyml_stats
    tuple val(id), path("*_codonphyml_tree.txt"),      emit: codonphyml_tree
    tuple val(id), path("*_codonphyml_tree.txt.orig"), emit: original_codonphyml_tree, optional: true

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: fa_alignment.baseName
    """
    codonphyml \\
        -i $fa_alignment \\
        $args

    if [ -f "$foregound_species" ]; then 
        find . -type f -name "*_codonphyml_tree.txt" \\
            -exec cp {} {}.orig \\; \\
            -exec bash $projectDir/bin/label_foreground_species.sh {} $foreground_species \\;
    fi
    """

}
