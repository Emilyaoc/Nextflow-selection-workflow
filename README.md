# Workflow

## Usage:

Usage:
```bash
nextflow run -c <custom config> -profile <profile> -params-file params.yml <nextflow script> [ -entry VALIDATE_SEQUENCES ]
```

where 

There are two workflows which can be run.
- `VALIDATE_SEQUENCES` only: Enable by including `-entry VALIDATE_SEQUENCES` in the workflow run command. Runs only the sequence validation workflow.
- Full workflow: The full workflow is the default mode of running and runs both the `VALIDATE_SEQUENCES` workflow and `SELECTION_ANALYSES` workflow.

Workflow parameters should be supplied using a `params.yml` file. 

`params.yml`:
```yml
# SNIC Compute allocation (only for -profile uppmax/dardel)
project: 'snic20XX-YY-ZZ'

# workflow parameters
gene_sequences: /path/to/gene/sequences/*.fasta
species_tree: /path/to/species.tree
species_labels: /path/to/species.tsv # Optional two column file of species and their labels
run_codonphyml: false

# Tool settings
hyphy_test:
    absrel:
        U-01: '--branches Leaves'
        L-02: '--branches CB' # 'L-' prefix denotes species labels should be used
    BUSTED-PH.bf:
        L-11: '--branches CB --comparison PB --srv No'

# output
results: './results'
```

Hyphy tests are supplied to workflow using a nested mapping. The top level key is the name
of the test, and the key value pair underneath is the output label and settings to use. If
the output label is prefixed with an `L-`, then the species labels are also supplied to Hyphy.

Override `cpu`, `memory`, and `time` resources by creating a `nextflow.config` in your
launch directory (where you run `nextflow run ...`), that looks like:
```nextflow
process {
    withName: 'PRANK' {
        cpus   = 2
        memory = 20.GB
        time   = 1.d
    }
}
```

### Workflow parameter inputs

Mandatory:

- `gene_sequences`: A set of gene sequences in fasta format to be sanitized and aligned.
- `species_tree`: A species tree in Newick format to guide alignment.
- `hyphy_test`: The hyphy branch-site test to use. See parameter file above to see how tests and settings are supplied.

Optional:

- `species_labels`: A two column file of species and their labels.
- `run_codonphyml`: If true, run codonphyml to make a gene tree for hyphy (default: false) 
- `results`: The publishing path for results (default: `results`).
- `publish_mode`: (values: `'symlink'` (default), `'copy'`) The file
publishing method from the intermediate results folders
(see [Table of publish modes](https://www.nextflow.io/docs/latest/process.html#publishdir)).

### Workflow outputs

All results are published to the path assigned to the workflow parameter `results`.

- `00_Problematic_Sequences`: Sequences that failed sanitation. Intermediate stop codons were found.
- `01_Sanitized_Sequences/`: Sanitized gene sequences with trailing stop
codons removed.
- `02_Prank_alignment/`: Phylogenetically guided gene sequence alignments.
- `03_Codonphyml/`: Reconstructed phylogeny.
- `04_HyPhy_selection_analysis/<test>-<id>`: Hyphy selection analyses, and TSV of results.
- `pipeline_info/`: A folder containing workflow execution details (if -profile pipeline_info).

### Customisation for Uppmax and PDC-KTH

Custom profiles named `uppmax` and `dardel` are available to run this workflow specifically
on UPPMAX and PDC-KTH clusters respectively. The process `executor` is `slurm` so jobs are
submitted to the Slurm Queue Manager. All jobs submitted to slurm
must have a project allocation. This is automatically added to the `clusterOptions`
in the `uppmax` and `dardel` profiles. 

All Uppmax clusters have node local disk space to do
computations, and prevent heavy input/output over the network (which
slows down the cluster for all).
The path to this disk space is provided by the `$SNIC_TMP` variable, used by
the `process.scratch` directive in the `uppmax` profile. Lastly
the profile enables the use of Singularity so that all processes must be
executed within Singularity containers. See [nextflow.config](nextflow.config)
for the profile specification.

The profile is enabled using the `-profile` parameter to nextflow:

```bash
nextflow run -profile uppmax main.nf
```

Similarly, the `dardel` profile also enables the use of Singularity. However
Apptainer (formerly Singularity) must be made available using 
`module load` before using the workflow.

```bash
module load PDC apptainer
nextflow run -profile dardel main.nf
```

## Project structure

The workflow in this folder manages the execution of your analyses
from beginning to end.

```
Nextflow-selection-workflow/
 | - bin/                            Custom workflow scripts
 | - configs/                        Configuration files that govern workflow execution
 | - containers/                     Custom container definition files
 | - modules/                        Nextflow process definitions used in main.nf
 | - main.nf                         The workflow definition script
 \ - nextflow.config                 General Nextflow configuration
```
