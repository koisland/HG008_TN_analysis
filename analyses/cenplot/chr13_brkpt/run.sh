seqtk subseq \
    /project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa \
    <(printf "HG008-N_rc-chr13_chr13_hap1\t106855726\t108877529") > \
    HG008-N_rc-chr13_chr13_hap1_106855726_108877529.fa

# Rename manually so ID is below 50

RepeatMasker \
    -engine rmblast \
    -pa 40 \
    HG008-N_rc-chr13_chr13_hap1_106855726_108877529.fa \
    -dir HG008-N_rc-chr13_chr13_hap1_106855726_108877529/ \
    -species human
