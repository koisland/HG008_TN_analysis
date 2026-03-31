
# DMR regions
# Large cohen_h_low or effect
zcat /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_segments.bed.gz | \
    awk -v OFS="\t" '$4 == "different" && $15 > 0.8' | bgzip > /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_segments_different.bed.gz
tabix -p bed /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_segments_different.bed.gz
