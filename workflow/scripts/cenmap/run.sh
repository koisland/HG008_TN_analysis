#!/bin/bash

set -euo pipefail

snakemake -p \
    --configfile config/config_hg008.yaml \
    --workflow-profile workflow/profiles/lpc_all \
    -j 50
