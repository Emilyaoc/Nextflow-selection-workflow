# Configs - Workflow specific configs

This folder contains configuration specific to
the operation of the workflow and it's tools.
These are default values and can be overridden 
by creating another `nextflow.config` file in the
directory where you run Nextflow from (launch directory). 
The settings you provide in the launch directory
will take precedence, and for anything not provided,
Nextflow will take that from the `nextflow.config` file
in the repository.

Workflow analysis parameters should be supplied using a
`params.yml` in the launch directory and supplied to
Nextflow using the `-params-file` option. The `params.yml` 
will override any parameters defined in the `nextflow.config`
in the workflow repository (and in the launch directory too).

The `compute_resources.config` file contains
the specification of compute resources to request
from the cluster queue manager / workflow manager.
This file is included by each predefined profile
in `nextflow.config`.

The `publishDirs.config` file contains
the publishing paths of the analysis results.
It is included from within `nextflow.config`.

Software environment configuration is declared in the process
description block to keep package configuration
information visible in the process. It is also coded to allow
the use of Conda, Docker, or Singularity as package
managers. The format is taken directly from nf-core.

Workflow modules (processes) are coded using the nf-core
style of coding where mandatory files, optional files, and
mandatory command-line options are supplied using `input:`. Optional
command-line options are provided using a configuration string
called `ext.args` (See [nf-core documentation](https://nf-co.re/docs/contributing/components/ext_args)).
Where possible, the workflow has been designed such that user-defined
command-line options should be supplied using the `params.yml`, while
other command-line options are managed by the `modules.config`.