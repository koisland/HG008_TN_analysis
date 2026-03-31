set -euo pipefail

# create bigwig
score_prefix=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_score
cohen_prefix=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_cohen

zcat /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_pair.bed.gz | cut -f 1-3,5 > $score_prefix.bg
zcat /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_pair.bed.gz | cut -f 1-3,17 > $cohen_prefix.bg

bedGraphToBigWig \
    $score_prefix.bg \
    /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa.fai \
    $score_prefix.bw

bedGraphToBigWig \
    $cohen_prefix.bg \
    /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa.fai \
    $cohen_prefix.bw
