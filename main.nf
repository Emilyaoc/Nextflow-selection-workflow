#! /usr/bin/env nextflow
include { SANITIZE_STOP_CODONS } from './modules/sanitize_stop_codons'
include { PRANK } from './modules/prank'
include { PAML } from './modules/paml'
include { HYPHY } from './modules/hyphy'
include { JQ } from './modules/jq'
include { CODONPHYML } from './modules/codonphyml'

// The main workflow
workflow {
    log.info(
        """
    NBIS support 5875

    Measuring selection in avian immune genes
    ===================================

    """
    )

    // Check a project allocation is given for running on Uppmax clusters.
    if (workflow.profile == "uppmax" && !params.project) {
        error "Please provide a SNIC project number ( --project )!\n"
    }

    VALIDATE_SEQUENCES()
    SELECTION_ANALYSES(
        VALIDATE_SEQUENCES.out.sequences
    )
}

workflow VALIDATE_SEQUENCES {
    main:
    // Get data (from params.config if available)
    Channel
        .fromPath( params.gene_sequences, checkIfExists: true )
        .set { gene_seq_ch }

    // Check sequences for stop codons
    // and santize sequences if possible
    SANITIZE_STOP_CODONS(gene_seq_ch)
    SANITIZE_STOP_CODONS.out.fasta
        .filter { fasta -> fasta.baseName.endsWith("_nostop.fasta") }
        .set { gene_sequences }
    SANITIZE_STOP_CODONS.out.tsv.collectFile(
        name: 'failed_sequences.tsv',
        skip: 1,
        keepHeader: true,
        storeDir: "${params.results}/00_Problematic_Sequences",
    )

    emit:
    sequences = gene_sequences
}

workflow SELECTION_ANALYSES {
    take:
    gene_sequences

    main:
    // Phylogenetically-informed codon-based gene sequence alignment
    species_tree = file(params.species_tree, checkIfExists: true)
    PRANK(
        gene_sequences,
        species_tree,
    )
    if (params.run_codonphyml) {
        CODONPHYML(
            PRANK.out.paml_alignment
        )
        hyphy_input = PRANK.out.fasta_alignment.join(CODONPHYML.out.codonphyml_tree)
    }
    else {
        hyphy_input = PRANK.out.fasta_alignment.combine(Channel.value(species_tree))
    }
    // Hyphy branch-site selection tests
    HYPHY(
        hyphy_input,
        params.hyphy_test,
        params.species_labels ? file(params.species_labels, checkIfExists: true) : [],
    )
    // Hyphy JSON to TSV
    JQ(
        HYPHY.out.json,
        file("${projectDir}/configs/hyphy_jq_filters.jq", checkIfExists: true),
    )
    JQ.out.tsv.collectFile(
        name: 'allgenes.tsv',
        skip: 1,
        keepHeader: true,
        storeDir: "${params.results}/04_HyPhy_selection_analysis",
    )
}
