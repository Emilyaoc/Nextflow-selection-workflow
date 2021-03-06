#! /usr/bin/env python
from Bio.Seq import Seq
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
import csv
import sys

###
#   Usage:
#      locate_intermediate_stop_codons.py <input_fasta> <output_fasta> <output_csv>
#
#      where:
#          <input_fasta>  :  The fasta file to be checked for stop codons.
#                            Sequences are assumed to be nucleotides in 5'3' Frame 1
#          <output_fasta> :  The name of the fasta file to be written, which contains no stop codons
#          <output_csv>   :  The name of the csv file which reports sequences that have intermediate stop codons.
#                            If no sequences have intermediate stop codons, just the header line is written.
###

# Script adapted from https://www.biostars.org/p/296261/

def remove_stop_codons(gene, record, tsv, codon_stop_array = ["TAG","TGA","TAA"]):
    # Check if seq starts with start-codon and ends with stop-codon, or a similar codon with an N
    # Add codon to empty string unless it's a stop and then replace the sequence.
    # count stop codons
    tempRecordSeq = ""                                # Sequence without stop codons
    endOfSeq = False                                  # True if stop codon occurs at end of sequence
    stopCodonCount = 0
    sequenceLength = len(record.seq)
    seqstart = record.seq[0:0+3]
    seqend = record.seq[sequenceLength-3:sequenceLength]

    for index in range(0, sequenceLength, 3):
        codon = record.seq[index:index+3]
        if codon.upper() not in codon_stop_array:
            tempRecordSeq += codon
        else:
            stopCodonCount += 1
            if ( index >= sequenceLength - 3 ):
                endOfSeq = True
    if ( (stopCodonCount == 1 and not endOfSeq) or stopCodonCount > 1 ):
        tsv.writerow([ gene, record.id, stopCodonCount ])
    record.seq = tempRecordSeq
    return record

records_with_stop_codons = open(sys.argv[3], 'w', newline='')
prefix = (sys.argv[2])[:-13]
tsv_file = csv.writer(records_with_stop_codons, delimiter='\t',lineterminator='\n')
tsv_file.writerow(['Gene','Sequence','Num Stop Codons'])
records = (remove_stop_codons(prefix,record, tsv_file) for record in SeqIO.parse(sys.argv[1], "fasta"))
SeqIO.write(records,sys.argv[2],"fasta")
records_with_stop_codons.close()
