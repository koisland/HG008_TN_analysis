# regions=/project/logsdon_shared/projects/GIAB_HG008_TN/results/7-fix_cens_w_repeatmasker/bed/interm/HG008-N_complete_cens.bed
ref=/project/logsdon_shared/projects/GIAB_HG008_TN/results/2-concat_asm/HG008-N-asm-renamed-reort.fa
dmr_result=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_pair.bed
dmr_segment_result=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_segments.bed
dmr_log=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/HG008-TN_dmr_pair.log
norm_pileup=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-N_pileup.bed.gz
tumor_pileup=/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-T_pileup.bed.gz
threads=40

modkit dmr pair \
  -a ${norm_pileup} \
  -b ${tumor_pileup} \
  -o ${dmr_result} \
  --ref ${ref} \
  --base C \
  --segment ${dmr_segment_result} \
  --header \
  --delta 0.3 \
  --min-valid-coverage 5 \
  --threads ${threads} \
  --log-filepath ${dmr_log}
  
sort -k 1,1 -k 2,2n ${dmr_result} | bgzip -c > ${dmr_result}.gz
sort -k 1,1 -k 2,2n ${dmr_segment_result} | bgzip -c > ${dmr_segment_result}.gz
tabix -p bed ${dmr_result}.gz
tabix -p bed ${dmr_segment_result}.gz
