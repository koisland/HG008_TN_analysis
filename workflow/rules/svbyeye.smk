
cases = {
    "chr7_hap2_dupe": {
        "HG008-T": "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/11-moddotplot/combined/bed/all/HG008-T_v3.2_chr6_chr7_chr11_hap2:60228206-67527215/stv.bed",
        "HG008-N": "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/11-moddotplot/combined/bed/all/HG008-N_v6.3_chr7_hap2:57312660-64850688/stv.bed",
    }
}

rule run_annot_aligner:
    input:
        t_hor_bed=lambda wc: cases[wc.case]["HG008-T"],
        n_hor_bed=lambda wc: cases[wc.case]["HG008-N"],
    output:
        aln=join(results_dir, "sv_by_eye", "{case}_aln.tsv"),
        gaps=join(results_dir, "sv_by_eye", "{case}_gaps.tsv"),
    params:
        temp_dir=join(results_dir, "sv_by_eye", "temp"),
        script="workflow/scripts/annotaligner/annotaligner.py",
    shell:
        """
        # Link so name is added to alignment tsv.
        mkdir -p {params.temp_dir}
        linked_t="{params.temp_dir}/HG008_T_{wildcards.case}.bed"
        linked_n="{params.temp_dir}/HG008_N_{wildcards.case}.bed"
        ln -s {input.t_hor_bed} "${{linked_t}}"
        ln -s {input.n_hor_bed} "${{linked_n}}"

        python {params.script} \
        "${{linked_n}}" \
        "${{linked_t}}" \
        --out-align {output.aln} \
        --out-gaps {output.gaps}
        """


rule format_bedfiles:
    input:
        bed_query="/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/final/bed/HG008-T_v3.2_complete_cens.bed",
        bed_target="/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/final/bed/HG008-N_v6.3_complete_cens.bed",
    output:
        bed_query=join(results_dir, "sv_by_eye", "HG008-T_cens.bed"),
        bed_target=join(results_dir, "sv_by_eye", "HG008-N_cens.bed"),
    shell:
        """
        awk -v OFS="\\t" '{{ print $4, $2, $3}}' {input.bed_target} > {output.bed_target}
        awk -v OFS="\\t" '{{ print $4, $2, $3}}' {input.bed_query} > {output.bed_query}
        """


rule plot_svbyeye:
    input:
        paf=expand(rules.asm_ref_bam_to_paf.output, ref="HG008-N_v6.3", sm="HG008-T_v3.2"),
        bed_query=rules.format_bedfiles.output.bed_query,
        bed_target=rules.format_bedfiles.output.bed_target,
        colors="/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/config/karyotype_colors_sorted.tsv"
    output:
        plots=directory(join(results_dir, "sv_by_eye", "plots")),
    params:
        script="workflow/scripts/plot_tn.R",
        ref_label="HG008-N_v6.3",
        ref_color="red",
        qry_label="HG008-T_v3.2",
        qry_color="blue",
    singularity:
        "/project/logsdon_shared/tools/containers/svbyeye.sif"
    shell:
        """
        Rscript {params.script} \
        -p {input.paf} \
        -r {input.bed_target} \
        --reference_color {params.ref_color} \
        --reference_label {params.ref_label} \
        -q {input.bed_query} \
        --query_color {params.qry_color} \
        --query_label {params.qry_label} \
        -c {input.colors} \
        -o {output.plots}
        """


rule svbyeye_all:
    input:
        expand(rules.run_annot_aligner.output, case=cases.keys()),
        rules.plot_svbyeye.output,
