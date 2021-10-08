# Configs - Workflow specific configs

This folder contains configuration specific to
the operation of the workflow and it's tools.
Workflow analysis parameters are instead kept
in their own file `params.config` under the
`analyses` folder. The `params.config` is used
to override default parameters provided by
`nextflow.config`.

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

When an included module contains an options parameter,
additional parameters to a module can be provided
via the `modules.config` file. These configuration
settings are then included through the `nextflow.config`
file, and passed to each module using the
`addParams(options:params.modules['module_name'])` function.

