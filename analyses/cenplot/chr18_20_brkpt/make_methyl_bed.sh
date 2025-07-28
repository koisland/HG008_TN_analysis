rgn="HG008-N_rc-chr18_chr18_hap1:24792827-25792827"
coords=$(echo $rgn | awk '{match($1, ":(.+)", coords); print coords[1]}')

modkit pileup \
    --region ${rgn} \
    /project/logsdon_shared/projects/GIAB_HG008_TN/results/8-cdr_finder/aln/HG008-N.bam \
    ${rgn}_methyl.bed \
    --cpg \
    --ref /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa \
    --threads 32 \
    --log-filepath ${rgn}.log

python /project/logsdon_shared/projects/GIAB_HG008_TN/workflow/rules/CDR-Finder/workflow/scripts/calculate_windows.py \
    -m ${rgn}_methyl.bed \
    -b <(echo $rgn | awk -v OFS="\t" '{match($1, "^(.+):", name); match($1, ":(.+)", coords); split(coords[1], st_end, "-"); print name[1], st_end[1], st_end[2]}') \
    --window_size 5000 | \
awk -v OFS="\t" -v COORDS=${coords} '{print $1":"COORDS, $2, $3, $4}' \
 > ${rgn}_avg_methyl.bedgraph
 