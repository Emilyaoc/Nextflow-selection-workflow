# Workflow

The workflows in this folder manage the execution of your analyses
from beginning to end.

```
Nextflow-selection-workflow/
 | - bin/                            Custom workflow scripts
 | - configs/                        Configuration files that govern workflow execution
 | - containers/                     Custom container definition files
 | - main.nf                         The primary analysis script
 | - nextflow.config                 General Nextflow configuration
 \ - params.config.TEMPLATE          A Template for parameter configuration
```

## Usage:

Usage:
```bash
nextflow run -c <custom config> -profile <profile> <nextflow script> [ -entry VALIDATE_SEQUENCES ]
```

There are two workflows which can be run.
- `VALIDATE_SEQUENCES` only: Enable by including `-entry VALIDATE_SEQUENCES` in the workflow run command. Runs only the sequence validation workflow.
- Full workflow: The full workflow is the default mode of running and runs both the `VALIDATE_SEQUENCES` workflow and `SELECTION_ANALYSES` workflow.

Workflow parameters can be provided in a custom configuration file.
A [template](params.config.TEMPLATE) is available to copy in this directory.
This can also be used to override workflow default settings.

Some tools used in the workflow can also be configured to use
alternative parameters such as `JQ`, `PRANK`, and `HYPHY`. Software
specific parameters are supplied to scripts using the `ext.args`
process directive. These are assigned in the file
`configs/modules.config`. Software specific parameters can be
overridden by updating the process selector configuration in a
custom configuration file. For example:

```
// Workflow parameters
...
// Software specific parameters
process {
    withName: 'HYPHY' {
        // Write diagnostic messages to log
        ext.args = '-m'
    }
}

<other configuration options>
...
```

### Workflow parameter inputs

Mandatory:

- `gene_sequences`: A set of gene sequences to be sanitized and aligned.
- `species_tree`: A species tree in Newick format to guide alignment.

Optional:

- `results`: The publishing path for results (default: `results`).
- `publish_mode`: (values: `'symlink'` (default), `'copy'`) The file
publishing method from the intermediate results folders
(see [Table of publish modes](https://www.nextflow.io/docs/latest/process.html#publishdir)).

    Software specific:
    - **HYPHY** `hyphy_test`: The hyphy branch-site test to use.
    Supported values are `absrel` (default), `busted`, and `fel`.

    Software package manager specific:
    - `enable_conda`: Set to `true` to use conda as the software package manager (default: `false`).
    - `singularity_pull_docker_container`: Set to `true` if Singularity images should be
    built from the docker images, instead of retrieving existing Singularity images (default: `false`).

    Uppmax cluster specific:
    - `project`: SNIC Compute allocation number.
    - `clusterOptions`: Additional Uppmax cluster options (e.g., `-M snowy`).

### Workflow outputs

All results are published to the path assigned to the workflow parameter `results`.

- `00_Problematic_Sequences`: Sequences that failed sanitation. Intermediate stop codons were found.
- `01_Sanitized_Sequences/`: Sanitized gene sequences with trailing stop
codons removed.
- `02_Prank_alignment/`: Phylogenetically guided gene sequence alignments.
- `03_HyPhy_selection_analysis/`: Hyphy selection analyses, and TSV of results.
- `pipeline_info/`: (Optional: See
[params template](params.config.TEMPLATE))
A folder containing workflow execution details.

### Customisation for Uppmax

A custom profile named `uppmax` is available to run this workflow specifically
on UPPMAX clusters. The process `executor` is `slurm` so jobs are
submitted to the Slurm Queue Manager. All jobs submitted to slurm
must have a project allocation. This is automatically added to the `clusterOptions`
in the `uppmax` profile. All Uppmax clusters have node local disk space to do
computations, and prevent heavy input/output over the network (which
slows down the cluster for all).
The path to this disk space is provided by the `$SNIC_TMP` variable, used by
the `process.scratch` directive in the `uppmax` profile. Lastly
the profile enables the use of Singularity so that all processes must be
executed within Singularity containers. See [nextflow.config](nextflow.config)
for the profile specification.

The profile is enabled using the `-profile` parameter to nextflow:
```bash
nextflow run -profile uppmax <nextflow_script>
```
