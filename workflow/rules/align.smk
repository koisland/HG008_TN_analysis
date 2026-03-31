ALN_CFG = {
    "ref": {"HG008-N_v6.3": asms["HG008-N_v6.3"]["asm_fa"]},
    "sm": {
        "HG008-T_v3.2": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-T_v3.2/HG008T_v3.2.fa.gz"
    },
    "temp_dir": join(results_dir, "asm_to_ref", "temp"),
    "output_dir": join(results_dir, "asm_to_ref"),
    "logs_dir": join(logs_dir, "asm_to_ref"),
    "benchmarks_dir": join(benchmarks_dir, "asm_to_ref"),
    "aln_threads": 8,
    "aln_mem": "150GB",
    "mm2_opts": "-x asm20 --secondary=no -s 25000 -K 8G",
}


module align_asm_to_ref:
    snakefile:
        "asm-to-reference-alignment/workflow/Snakefile"
    config:
        ALN_CFG


use rule * from align_asm_to_ref as asm_ref_*


rule align_all:
    input:
        rules.asm_ref_all.input,
