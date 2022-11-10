process CODONPHYML {

    tag "${fa_alignment.simpleName}"

    container "ghcr.io/emilyaoc/codonphyml:1.0"

    input:
    tuple val(id), path(fa_alignment)
    path(species_labels)                    // Optional: Two column input file of Species followed by label e.g. Calocitta_formosa CB

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

    if [ -f "$species_labels" ]; then 
        find . -type f -name "*_codonphyml_tree.txt" \\
            -exec cp {} {}.orig \\; \\
            -exec label_species.sh {} $species_labels \\;
    fi
    """

}
