#!/bin/bash

set -euo pipefail

sed 's/\t\t/\t.\t/g' /project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/data/HG008-T_SV_Curation_VCF_Fields_SVcurationwithHG8Nv6.3.tsv | \
awk -v OFS="\t" '{
    if (NR == 1) {
        print "#chrom", "st", "end", "type";
        next
    }
    if ($36 == ".") { next };
    end=($48 == ".") ? $37 + 1 : $48;
    print $36, $37, end, $41
}' > data/HG008N_6.3_SV.bed
