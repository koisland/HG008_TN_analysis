CFG = {
    "samples": [
        {
            "name": "HG008-N_to_HG008-T_ont",
            "asm_fa": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-T_v3.2/HG008T_v3.2.fa.gz",
            "read_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/ont/HG008-N-P/",
            "read_rgx": r".*\.bam",
        },
        {
            "name": "HG008-N_to_HG008-T_hifi",
            "asm_fa": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-T_v3.2/HG008T_v3.2.fa.gz",
            "read_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/hifi/HG008-N-P/",
            "read_rgx": r".*\.bam",
        }
    ],
    "aligner": "minimap2",
    "aligner_opts": "-ax lr:hq --eqx",
    "output_dir": "results/breakpoints",
    "output_format": "bam",
    "logs_dir": "logs/breakpoints",
    "benchmarks_dir": "benchmarks/breakpoints",
    "threads_aln": 8,
    "mem_aln": "50G",
}


module AlignONTBreakpoints:
    snakefile:
        "Snakemake-Aligner/workflow/Snakefile"
    config: CFG

use rule * from AlignONTBreakpoints as ont_brkpts_*

rule breakpoints_all:
    input:
        expand(rules.ont_brkpts_align.input, sm="HG008-N_to_HG008-T"),
