SM_DTYPES = [(sm, dtype) for sm in asms.keys() for dtype in reads.keys()]

NUCFLAG_CFG = {
    "samples": [
        {
            "name": f"{sm}_{dtype}",
            **asms[sm],
            **reads[dtype]["HG008-T" if "HG008-T" in sm else "HG008-N"],
            "config": (
                "config/nucflag_ont_r10.toml"
                if dtype == "ont"
                else "config/nucflag_hifi.toml"
            ),
        }
        for sm, dtype in SM_DTYPES
    ],
    "output_dir": join(results_dir, "nucflag"),
    "logs_dir": join(logs_dir, "nucflag"),
    "benchmarks_dir": join(benchmarks_dir, "nucflag"),
    "processes_nucflag": 24,
    "threads_nucflag": 24,
    "threads_aln": 12,
    "mem_aln": "50GB",
    "mem_nucflag": "50GB",
    "samtools_view_flag": 2308,
}


module NucFlag:
    snakefile:
        "Snakemake-NucFlag/workflow/Snakefile"
    config:
        NUCFLAG_CFG


use rule * from NucFlag as all_*


rule generate_qv:
    input:
        bed=rules.all_check_asm_nucflag.output.misassemblies,
    output:
        bed_qv=join(results_dir, "nucflag", "{sm}_qv.bed"),
    conda:
        "Snakemake-NucFlag/workflow/env/nucflag.yaml"
    params:
        omit=" ".join(["scaffold", "het_or_mismap"]),
        grep_chr=lambda wc, input: (
            input.bed if "HG008-T" in wc.sm else f"<(grep chr {input.bed})"
        ),
    shell:
        """
        nucflag qv -i {params.grep_chr} -c {params.omit} > {output.bed_qv}
        """


rule generate_breakdown:
    input:
        bed_status=lambda wc: expand(
            rules.all_check_asm_nucflag.output.status,
            sm=[f"{sm_version}_{wc.dtype}" for sm_version in sample_versions[wc.sm]],
        ),
    output:
        plot=join(results_dir, "nucflag", "{sm}_{dtype}_breakdown.png"),
        tsv=join(results_dir, "nucflag", "{sm}_{dtype}_breakdown.tsv"),
    conda:
        "../envs/python.yaml"
    params:
        script="workflow/scripts/nucflag/breakdown_by_version.py",
        labels=lambda wc: " ".join(sample_versions[wc.sm]),
    shell:
        """
        python {params.script} -i {input.bed_status} -l {params.labels} -p {output.plot} -t {output.tsv}
        """


rule qv_plot_by_version:
    input:
        bed_qvs=lambda wc: expand(
            rules.generate_qv.output,
            sm=[f"{sm_version}_hifi" for sm_version in sample_versions[wc.sm]],
        ),
    output:
        bed_qv_plot=join(results_dir, "nucflag", "{sm}_qv.png"),
    conda:
        "../envs/python.yaml"
    params:
        script="workflow/scripts/nucflag/qv_by_version.py",
        labels=lambda wc: " ".join(sample_versions[wc.sm]),
    shell:
        """
        python {params.script} -i {input.bed_qvs} -l {params.labels} -o {output.bed_qv_plot}
        """


rule format_curated_tn_sv_calls:
    input:
        svs=curated_svs,
    output:
        svs=join(
            results_dir,
            "nucflag",
            "curated",
            "HG008-T_SV_Curation_VCF_Fields_SVcurationwithHG8Nv6.3.bed",
        ),
    shell:
        """
        sed 's/\\t\\t/\\t.\\t/g' {input.svs} | \
        awk -v OFS="\\t" '{{
            if (NR == 1) {{
                print "#chrom", "st", "end", "type";
                next
            }}
            if ($36 == ".") {{ next }};
            end=($48 == ".") ? $37 + 1 : $48;
            st=$37;
            if (st > end) {{
                print $36, end, st, "\\""$41"\\""
            }} else {{
                print $36, st, end, "\\""$41"\\""
            }}
        }}' > {output.svs}
        """


rule intersect_curated_tn_sv_calls_w_nucflag:
    input:
        svs=rules.format_curated_tn_sv_calls.output,
        bed_normal=rules.all_check_asm_nucflag.output.misassemblies,
    output:
        svs=join(
            results_dir,
            "nucflag",
            "curated",
            "HG008-T_SV_Curation_VCF_Fields_SVcurationwithHG8Nv6.3_intersection_{sm}.bed",
        ),
    conda:
        "../envs/python.yaml"
    shell:
        """
        bedtools intersect \
        -a {input.svs} -b <(grep -v correct {input.bed_normal}) \
        -nonamecheck -wa -wb > {output.svs}
        """


rule breakdown_by_censat:
    input:
        bed_normal=rules.all_check_asm_nucflag.output.misassemblies,
        # HG008-N_v6.3_hifi
        bed_censat=lambda wc: censat[wc.sm.rsplit("_", 1)[0]],
    output:
        censat_plot=join(results_dir, "nucflag", "{sm}_by_censat.png"),
        censat_tsv=join(results_dir, "nucflag", "{sm}_by_censat.tsv"),
    conda:
        "../envs/python.yaml"
    params:
        script="workflow/scripts/nucflag/breakdown_by_censat.py",
    shell:
        """
        python {params.script} \
        -i {input.bed_normal} \
        -c <(cat {input.bed_censat}) \
        -p {output.censat_plot} \
        -t {output.censat_tsv}     
        """


rule nucflag_all:
    input:
        rules.all_nucflag.input,
        expand(
            rules.generate_qv.output,
            sm=[f"{sm}_{dtype}" for sm, dtype in SM_DTYPES if dtype == "hifi"],
        ),
        expand(
            rules.generate_breakdown.output,
            sm=sample_versions.keys(),
            dtype=("hifi", "ont"),
        ),
        expand(
            rules.intersect_curated_tn_sv_calls_w_nucflag.output,
            sm=[f"HG008-N_v6.3_{dtype}" for dtype in ("hifi", "ont")],
        ),
        expand(rules.qv_plot_by_version.output, sm=sample_versions.keys()),
        expand(
            rules.breakdown_by_censat.output,
            sm=[
                f"{sm}_{dtype}"
                for sm, dtype in SM_DTYPES
                if sm in ("HG008-N_v6.3", "HG008-T_v3.2")
            ],
        ),
