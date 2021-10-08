#! /usr/bin/env bash

display_stop_codon () {
    # $1 is a single-line fasta file
	# sed - if line does not begin with >,
	#       insert a space every three characters
	# grep - highlight the triplets TAG, TGA, and TAA
	sed '/^[^>]/ s/.\{3\}/& /g' "$1" \
	    | grep -i --color=always "TAG\|TGA\|TAA\|$"
}

display_stop_codon "$1"
