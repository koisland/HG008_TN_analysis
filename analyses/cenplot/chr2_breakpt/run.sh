set -euo pipefail

contig=HG008-N_chr2_chr2_hap2
start=79418214
stop=85418213

full_name="${contig}:${start}-${stop}"
full_name_one="${contig}:$(echo "$start+1" | bc)-${stop}"
itv="${contig}\t${start}\t${stop}"

out_fa=${full_name}.fa
out_sat_annot="${full_name}_sat_annot.bed"
out_methyl_bed="${full_name}_methyl.bed"
out_methyl_bedgraph="${full_name}_avg_methyl.bedgraph"
out_mdp_bed="${full_name}/${full_name}_no_header.bed"
out_yaml=run.yaml

seqtk subseq \
    /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa \
    <(printf "${itv}") > ${out_fa}

moddotplot static \
    -f "${out_fa}" \
    -o "${full_name}" \
    -id 70.0 -w 5000 \
    --breakpoints $(cut -f 1 /project/logsdon_shared/projects/GIAB_HG008_TN/exp/repeatmasker/chr2_breakpt/param_breakpoints.tsv) \
    --colors $(cut -f 1 /project/logsdon_shared/projects/GIAB_HG008_TN/exp/repeatmasker/chr2_breakpt/param_colors.tsv)

conda run -p /project/logsdon_shared/projects/GIAB_HG008_TN/.snakemake/conda/955b63e2ddd07ba4f8a56702c0232261_ \
    RepeatMasker \
    -engine rmblast \
    -pa 40 \
    ${out_fa} \
    -dir "${full_name}" \
    -species human

python /project/logsdon_shared/projects/GIAB_HG008_TN/workflow/scripts/format_rm_sat_annot.py \
    -i <(awk -v OFS="\t" 'NR > 4 { $1=$1; print }' "${full_name}/${full_name}.fa.out") \
    > ${full_name}_sat_annot.bed


modkit pileup \
    --region ${full_name} \
    /project/logsdon_shared/projects/GIAB_HG008_TN/results/8-cdr_finder/aln/HG008-N.bam \
    ${out_methyl_bed} \
    --cpg \
    --ref /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa \
    --threads 32

python /project/logsdon_shared/projects/GIAB_HG008_TN/workflow/rules/CDR-Finder/workflow/scripts/calculate_windows.py \
    -m ${out_methyl_bed} \
    -b <(printf "${itv}") \
    --window_size 5000 | \
awk -v OFS="\t" -v ST=$start -v STOP=$stop '{print $1":"ST+1"-"STOP, $2, $3, $4}' \
 > ${full_name}_avg_methyl.bedgraph
 
tail -n+2 ${full_name}/*.bed > ${out_mdp_bed}
sed -e "s|~methyl|${out_methyl_bedgraph}|g" -e "s|~rm|${out_sat_annot}|g" -e "s|~ident|${out_mdp_bed}|g" /project/logsdon_shared/projects/GIAB_HG008_TN/exp/repeatmasker/chr2_breakpt/cenplot.yaml > run.yaml

cenplot draw -t run.yaml -c ${full_name_one} -d .