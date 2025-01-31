process HYPHY {
    // directives:
    tag "${fasta.simpleName}"
    conda "bioconda::hyphy:2.5.65"
    container "${workflow.containerEngine in [ 'singularity', 'apptainer' ] ?
        "https://depot.galaxyproject.org/singularity/hyphy:2.5.65--he91c24d_0" :
        "quay.io/biocontainers/hyphy:2.5.65--he91c24d_0" }"

    input:
    tuple (
        val(metadata), 
        path(fasta), 
        path(tree), 
        val(test),
        path(species_labels)  // Optional: option file to relabel species with
    )

    script:
    def args  = task.ext.args  ?: '' // command-line args for hyphy <test>
    def args2 = task.ext.args2 ?: '' // optional command-line args for hyphy label-tree
    """
    if [ -f "$species_labels" ]; then
        # $species_labels is a two column file
        # Awk makes a label.spp file containing all species (\$1) with that label (\$2)
        awk '{ print \$1 >> ( \$2 ".spp" ) }' $species_labels
        # Use an intermediate file for relabelling
        cp $tree ${tree.baseName}.intermediate.nwk
        # Iterate over labels
        for SPP in *.spp; do
            hyphy $projectDir/bin/label-tree.bf \\
                --tree ${tree.baseName}.intermediate.nwk \\
                --list \$SPP \\
                --label \${SPP%.spp} \\
                --output ${tree.baseName}.relabeled.nwk $args2
            cp ${tree.baseName}.relabeled.nwk ${tree.baseName}.intermediate.nwk
        done 
    fi

    # Hyphy test: If ends with .bf, will look for script in bin folder
    hyphy ${test.endsWith('.bf') ? "$projectDir/bin/$test" : test} \\
        --alignment $fasta \\
        --tree ${species_labels ? "${tree.baseName}.relabeled.nwk" : tree} \\
        $args \\
        ENV="TOLERATE_NUMERICAL_ERRORS=1;"
    """

    output:
    tuple val(metadata), path("*.json")           , emit: json
    path "*.relabeled.nwk", emit: relabeled_newick, optional: true
}
