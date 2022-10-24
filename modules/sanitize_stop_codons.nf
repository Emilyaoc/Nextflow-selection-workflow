process SANITIZE_STOP_CODONS {

    tag "${sequences.baseName}"

    // Behavior:
    //   Assumptions:
    //     - Sequences are in 5'3' Frame 1
    //   Output:
    //     - CSV with list of sequences containing
    //       intermediate stop codons.
    //     - Removes trailing stop codons.

    conda (params.enable_conda ? "conda-forge::biopython:1.78" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/biopython:1.78"
    } else {
        container "quay.io/biocontainers/biopython:1.78"
    }

    input:
    path sequences

    output:
    path "*.fasta"                , emit: fasta
    path "*_stop_codon_count.tsv" , emit: tsv  , optional: true

    script:
    prefix = sequences.baseName
    """
    locate_intermediate_stop_codons.py $sequences ${prefix}_nostop.fasta ${prefix}_stop_codon_count.tsv

    if [[ \$( wc -l < ${prefix}_stop_codon_count.tsv ) -gt 1 ]]; then
        mv ${prefix}_nostop.fasta ${prefix}_stops.fasta
    else
        rm ${prefix}_stop_codon_count.tsv
    fi
    """
}
