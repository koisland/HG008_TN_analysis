rgn="HG008-N_rc-chr18_chr18_hap1\t24792827\t25792827"
rgn_str=$(printf "${rgn}" | sed 's/\t/_/g')
# seqtk subseq \
#     /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa \
#     <(printf ${rgn}) > \
#     "${rgn_str}.fa"

# Rename manually so ID is below 50

# conda run -p /project/logsdon_shared/projects/GIAB_HG008_TN/.snakemake/conda/955b63e2ddd07ba4f8a56702c0232261_ \
#     RepeatMasker \
#     -engine rmblast \
#     -pa 40 \
#     "${rgn_str}.fa" \
#     -dir "${rgn_str}/" \
#     -species human

python /project/logsdon_shared/projects/GIAB_HG008_TN/workflow/scripts/format_rm_sat_annot.py \
    -i <(awk -v OFS="\t" 'NR > 4 { $1=$1; print }' HG008-N_rc-chr18_chr18_hap1_24792827_25792827/HG008-N_rc-chr18_chr18_hap1_24792827_25792827.fa.out) \
    --add_ct > HG008-N_rc-chr18_chr18_hap1_24792827_25792827_rm_sat_annot.bed