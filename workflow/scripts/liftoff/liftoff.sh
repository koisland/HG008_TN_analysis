#!/bin/bash

set -euo pipefail

asm_hg38=$1
gff_hg38=$2

# /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa
asm_norm=$3
# /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-T-asm-renamed-reort.fa
asm_tumor=$4

liftoff ${asm_norm} ${asm_hg38} -g ${gff_hg38} -o "norm.gff" -u "unmapped_norm.txt"
liftoff ${asm_tumor} ${asm_hg38} -g ${gff_hg38} -o "tumor.gff" -u "unmapped_tumor.txt"

gzip norm.gff
gzip tumor.gff