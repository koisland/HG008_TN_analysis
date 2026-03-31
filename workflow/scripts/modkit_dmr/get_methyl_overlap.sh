bedtools intersect \
    -a /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_pair_bh.bed.gz \
    -b /project/logsdon_shared/projects/GIAB_HG008_TN/exp/liftoff/norm_genes_methyl.bed -wb | \
    grep -P "Liftoff\tgene" | \
    bedtools groupby -g 1,31 -c 15,17 -o collapse,collapse > \
    /project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_methyl-gene_dmr_overlap.bed
