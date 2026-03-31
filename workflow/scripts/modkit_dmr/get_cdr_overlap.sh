bedtools intersect \
    -a <(awk -v OFS="\t" '{ match($1, "(.+):", elems); print elems[1], $2, $3}' /project/logsdon_shared/projects/GIAB_HG008_TN/results/8-cdr_finder/bed/all_cdrs.bed | grep N) \
    -b /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_segments_different.bed.gz \
    -loj > /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_cdr_dmr_overlap.bed
    