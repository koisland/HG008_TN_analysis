#!/bin/bash

set -euo pipefail

outdir="${1}"

samtools faidx \
    /project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/8-humas_annot/seq/HG008-T_v3.2_chr6_chr7_chr11_hap2:60228206-67527215.fa \
    HG008-T_v3.2_chr6_chr7_chr11_hap2:60228206-67527215:4181097-4181245 > "${outdir}/HG008-T_v3.2_chr6_chr7_chr11_hap2:60228206-67527215:4181097-4181357.fa"
