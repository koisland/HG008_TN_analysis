
# Rule to rerun moddotplot on centromere regions around breakpoints and on whole chromosome level.
checkpoint generate_all_pairs:
    input:
        cen_directory="/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/8-humas_annot/seq",
    output:
        all_pairs=join(results_dir, "moddotplot", "all_pairs.csv"),
    log:
        all_pairs=join(logs_dir, "moddotplot", "all_pairs.log"),
    params:
        script="workflow/scripts/moddotplot/build_all_pairs.py"
    shell:
        """
        python {params.script} {input.cen_directory} > {output.all_pairs} 2> {log}
        """


rule run_moddotplot_compare:
    input:
        all_pairs=rules.generate_all_pairs.output,
        breakpoints="config/moddotplot_breakpoints.tsv",
        colors="config/moddotplot_colors.tsv",
    output:
        touch(join(results_dir, "moddotplot", "{pair}.done")),
    log:
        join(logs_dir, "moddotplot", "{pair}.log"),
    params:
        threshold=70.0,
        window=5000,
        outdir=join(results_dir, "moddotplot", "{pair}")
    shell:
        """
        while IFS= read -r line; do
            fa_ref=$(echo "${{line}}"| cut -d, -f 2)
            fa_qry=$(echo "${{line}}"| cut -d, -f 3)
            bname_1=$(basename "${{fa_ref}}" .fa)
            bname_2=$(basename "${{fa_qry}}" .fa)
            pair_id=$(echo "${{bname_1}}~${{bname_2}}" | sed 's/:/_/g')
            
            outdir="{params.outdir}/${{pair_id}}"
            mkdir -p "${{outdir}}"
            multifasta="{params.outdir}/${{pair_id}}.fa"
            cat "${{fa_ref}}" "${{fa_qry}}" > "${{multifasta}}"
            
            moddotplot static \
                --compare-only \
                -f "${{multifasta}}" \
                -o "${{outdir}}" \
                -id {params.threshold} \
                -w {params.window} \
                --breakpoints $(cut -f 1 {input.breakpoints}) \
                --colors $(cut -f 1 {input.colors}) 2>> {log}
        done < <(grep "{wildcards.pair}" {input.all_pairs})
        """

# Other breakpoints outside of centromere
checkpoint generate_pairs_other_breakpoints:
    input:
        bedpe="data/HG008-TN_other_breakpoints.bedpe",
        t_fa="/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-T_v3.2/HG008T_v3.2.fa.gz",
        n_fa=asms["HG008-N_v6.3"]["asm_fa"],
    output:
        all_pairs=join(results_dir, "moddotplot_others", "all_pairs.csv"),
    params:
        script="workflow/scripts/moddotplot/built_other_pairs_from_bedpe.py",
        outdir_fa=lambda wc, output: dirname(str(output))
    log:
        all_pairs=join(logs_dir, "moddotplot_other", "all_pairs.log"),
    shell:
        """
        python {params.script} {input.bedpe} {input.t_fa} {input.n_fa} {params.outdir_fa} > {output}
        """

rule moddotplot_other_breakpoints:
    input:
        brkpts="data/HG008-TN_other_breakpoints.bed",
        n_fa="/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/2-concat_asm/HG008-N_v6.3-asm-comb-dedup.fa",
        n_renamed_fa="/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/2-concat_asm/HG008-N_v6.3-asm-renamed.fa",
        n_renamed_bam="/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/8-cdr_finder/aln/HG008-N_v6.3.bam",
    output:
        chkpt=touch(join(results_dir, "moddotplot_others", "self_ident.done")),
    params:
        script="workflow/scripts/moddotplot/plot_other_breakpoints.sh",
        outdir=join(results_dir, "moddotplot_others", "self_ident"),
    log:
        join(logs_dir, "moddotplot_others", "other_self_ident.log"),
    shell:
        """
        bash {params.script} {input.brkpts} {input.n_fa} {input.n_renamed_fa} {input.n_renamed_bam} {params.outdir} &> {log}
        """
        

use rule run_moddotplot_compare as run_moddotplot_compare_others with:
    input:
        all_pairs=rules.generate_pairs_other_breakpoints.output,
        breakpoints="config/moddotplot_breakpoints.tsv",
        colors="config/moddotplot_colors.tsv",
    output:
        touch(join(results_dir, "moddotplot_others", "{pair}.done")),
    log:
        join(logs_dir, "moddotplot_others", "{pair}.log"),
    params:
        threshold=70.0,
        window=5000,
        outdir=join(results_dir, "moddotplot_others", "{pair}")


def all_moddotplot_compare_output(wc):
    file = checkpoints.generate_all_pairs.get(**wc).output
    pairs = []
    with open(str(file), "rt") as fh:
        for line in fh:
            pair_id, _, _ = line.strip().split(",")
            pairs.append(pair_id)
    return expand(
        rules.run_moddotplot_compare.output,
        pair=pairs
    )


def all_moddotplot_compare_other_output(wc):
    file = checkpoints.generate_pairs_other_breakpoints.get(**wc).output
    pairs = []
    with open(str(file), "rt") as fh:
        for line in fh:
            pair_id, _, _ = line.strip().split(",")
            pairs.append(pair_id)
    return expand(
        rules.run_moddotplot_compare_others.output,
        pair=pairs
    )


rule finish_moddotplot_compare:
    input:
        all_moddotplot_compare_output,
    output:
        touch(join(results_dir, "moddotplot", "all.done"))


rule finish_moddotplot_compare_other:
    input:
        all_moddotplot_compare_other_output,
    output:
        touch(join(results_dir, "moddotplot_others", "all.done"))


rule moddotplot_all:
    input:
        rules.finish_moddotplot_compare.output,
        rules.finish_moddotplot_compare_other.output,
        rules.generate_pairs_other_breakpoints.output,
        rules.moddotplot_other_breakpoints.output,
