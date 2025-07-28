moddotplot static \
    -f /project/logsdon_shared/projects/GIAB_HG008_TN/exp/repeatmasker/chr18_20_brkpt/HG008-N_rc-chr18_chr18_hap1_24792827_25792827.fa \
    -o HG008-N_rc-chr18_chr18_hap1_24792827_25792827_mdp \
    -id 70.0 -w 5000 \
    --breakpoints $(cut -f 1 /project/logsdon_shared/projects/GIAB_HG008_TN/exp/repeatmasker/chr18_20_brkpt/param_breakpoints.tsv) \
    --colors $(cut -f 1 /project/logsdon_shared/projects/GIAB_HG008_TN/exp/repeatmasker/chr18_20_brkpt/param_colors.tsv)
    