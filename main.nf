#! /usr/bin/env nextflow
include { SANITIZE_STOP_CODONS } from './modules/sanitize_stop_codons'
include { PRANK                } from './modules/prank'
include { APE                  } from './modules/ape'
include { PAML                 } from './modules/paml'
include { HYPHY                } from './modules/hyphy'
include { JQ                   } from './modules/jq'
include { CODONPHYML           } from './modules/codonphyml'

// The main workflow
workflow {
    VALIDATE_SEQUENCES()
    SELECTION_ANALYSES(
        VALIDATE_SEQUENCES.out.sequences
    )
}

workflow VALIDATE_SEQUENCES {
    main:
    log.info(
        """
    NBIS support 5875

    Measuring selection in avian immune genes
    ===================================

    """
    )

    // Check a project allocation is given for running on Uppmax clusters.
    if (workflow.profile.tokenize(',').intersect([ 'uppmax, dardel' ]) && !params.project) {
        error "Please provide a SNIC project number ( --project )!\n"
    }

    Channel
        .fromPath( params.gene_sequences, checkIfExists: true )
        .set { gene_seq_ch }

    // Check sequences for stop codons
    // and santize sequences if possible
    SANITIZE_STOP_CODONS(gene_seq_ch)
    SANITIZE_STOP_CODONS.out.fasta
        .filter { fasta -> fasta.name.endsWith("_nostop.fasta") }
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
    // Check input
    if( params.hyphy_test && params.hyphy_test.values().every{ entry -> entry instanceof Map } ) {
        if( params.hyphy_test.keySet().any{ key -> key.startsWith('L-') && ! params.species_labels } ) {
            error """
                Error: Some inputs have been marked as using species labels ('L-' prefix),
                    but `params.species_labels` has not been supplied.
            """.stripIndent()
        }
    } else {
        error "Error: Please supply one or more hyphy tests as described in the README!\n"
    }

    // Phylogenetically-informed codon-based gene sequence alignment
    species_tree = Channel.fromPath(params.species_tree, checkIfExists: true)
    PRANK(
        gene_sequences,
        species_tree.collect(),
    )
    if (params.run_codonphyml) {
        CODONPHYML( PRANK.out.paml_alignment )
        hyphy_input = PRANK.out.fasta_alignment.join( CODONPHYML.out.codonphyml_tree )
    } else {
        APE( PRANK.out.fasta_headers.combine( species_tree) )
        hyphy_input = PRANK.out.fasta_alignment.join( APE.out.tree )
    }
    // Hyphy branch-site selection tests
    ch_hyphy_input = hyphy_input.filter { params.hyphy_test }
        .flatMap{ id, path, tree ->
            params.hyphy_test
                .keySet() // Get test names
                .collectMany { test ->
                    params.hyphy_test[test].collect { setting_id, settings ->
                        tuple( 
                            [ sample_id: id, setting_id: setting_id, settings: (settings?: '') ] , 
                            path, 
                            tree, 
                            test,
                            params.species_labels && setting_id.startsWith('L-') ? file(params.species_labels, checkIfExists: true) : [] 
                        )
                    } // Produce list of hyphy inputs
                }
        }
    HYPHY( ch_hyphy_input )
    // Hyphy JSON to TSV
    JQ(
        HYPHY.out.json,
        file("${projectDir}/configs/hyphy_jq_filters.jq", checkIfExists: true)
    )
    JQ.out.tsv.collectFile(
        name: 'allgenes.tsv',
        skip: 1,
        keepHeader: true,
        storeDir: "${params.results}/04_HyPhy_selection_analysis",
    )
}
