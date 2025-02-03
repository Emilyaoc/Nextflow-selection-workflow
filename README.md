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
# NAISS Compute allocation (only for -profile dardel)
project: 'naiss20XX-YY-ZZ'

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
- `publish_mode`: (values: `'symlink'`, `'copy'` (default)) The file
publishing method from the intermediate results folders
(see [Table of publish modes](https://www.nextflow.io/docs/latest/reference/process.html#publishdir)).

### Workflow outputs

All results are published to the path assigned to the workflow parameter `results`.

- `00_Problematic_Sequences`: Sequences that failed sanitation. Intermediate stop codons were found.
- `01_Sanitized_Sequences/`: Sanitized gene sequences with trailing stop codons removed.
- `02_Prank_alignment/`: Phylogenetically guided gene sequence alignments.
- `03_Codonphyml/`: Reconstructed phylogeny.
- `04_HyPhy_selection_analysis/<test>-<id>`: Hyphy selection analyses, and TSV of results.
- `pipeline_info/`: A folder containing workflow execution details (if -profile pipeline_info).

### Customisation for PDC-KTH

Custom profiles named `dardel` and `dardel_local` are available to run this workflow specifically
on PDC-KTH clusters. The `dardel` profile utilizes the [nf-core pdc-kth profile](https://github.com/nf-core/configs/blob/master/conf/pdc_kth.config) 
which enables using the `slurm` executor so jobs are submitted to the Slurm Queue Manager. All jobs 
submitted to slurm must be associated to a NAISS project which is supplied using the `--project` 
workflow parameter. All jobs are executed within Apptainer containers (formerly Singularity). 
Remember to use `module load PDC apptainer` in order to use Apptainer with the workflow. Similarly, 
the `dardel_local` profile also uses Singularity containers, but executes everything locally. Follow
the instructions on [PDC_KTH - Interactive running](https://support.pdc.kth.se/doc/support-docs/run_jobs/run_interactively/) 
for running a job locally.

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
