#!/bin/bash

set -euo pipefail

outdir=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr
threads=32

ref=/project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa
norm=/project/logsdon_shared/projects/GIAB_HG008_TN/results/8-cdr_finder/aln/HG008-N.bam
norm_pileup="${outdir}/data/HG008-N_pileup.bed.gz"

modkit pileup ${norm} - \
--cpg \
--ref ${ref} \
--threads ${threads} \
--log-filepath "${outdir}/log_HG008-N.txt" | bgzip -c > ${norm_pileup}

tabix -p bed ${norm_pileup}

tumor=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/Snakemake-Aligner/results/align/HG008-N.bam
tumor_pileup="${outdir}/data/HG008-T_pileup.bed.gz"

modkit pileup ${tumor} - \
  --cpg \
  --ref ${ref} \
  --threads ${threads} \
  --log-filepath ${outdir}/log_HG008-T.txt | bgzip -c > ${tumor_pileup}

tabix -p bed ${tumor_pileup}
