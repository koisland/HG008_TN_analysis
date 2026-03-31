from os.path import join, splitext, dirname


results_dir = "results"
logs_dir = "logs"
benchmarks_dir = "benchmarks"
asms = {
    "HG008-N_v6.3": {
        "asm_fa": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-N_v6.3/HG008N_v6.3.fasta.gz",
    },
    "HG008-N_v6.2": {
        "asm_fa": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-N_v6.2/HG008N_curatedv6_250714_bothhaps_polished6.2.fasta.gz",
    },
    "HG008-N_v5.0": {
        "asm_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-N_v5.0/",
        "asm_rgx": ".*\\.fasta.gz$",
    },
    "HG008-T_v3.2": {
        "asm_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-T_v3.2",
        "asm_rgx": ".*\\.fasta.gz$",
    },
    "HG008-T_v3.1": {
        "asm_fa": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-T_v3.1/HG008T_curatedv3_250715_bothhaps_polished3.1.fasta.gz",
    },
    "HG008-T_v2.2.1": {
        "asm_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/HG008-T_v2.2.1/",
        "asm_rgx": ".*\\.fasta.gz$",
    },
}
reads = {
    "hifi": {
        "HG008-T": {
            "read_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/hifi/HG008-T/",
            "read_rgx": ".*\\.bam$",
        },
        "HG008-N": {
            "read_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/hifi/HG008-N-P/",
            "read_rgx": ".*\\.bam$",
        },
    },
    "ont": {
        "HG008-T": {
            "read_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/ont/HG008-T/",
            "read_rgx": ".*\\.bam$",
        },
        "HG008-N": {
            "read_dir": "/project/logsdon_shared/data/NIST_GIAB_HG008/ont/HG008-N-P/",
            "read_rgx": ".*\\.bam$",
        },
    },
}
sample_versions = {
    "HG008-T": ["HG008-T_v2.2.1", "HG008-T_v3.1", "HG008-T_v3.2"],
    "HG008-N": ["HG008-N_v5.0", "HG008-N_v6.2", "HG008-N_v6.3"],
}
curated_svs = "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/data/HG008-T_SV_Curation_VCF_Fields_SVcurationwithHG8Nv6.3.tsv"
censat = {
    "HG008-N_v6.3": [
        "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/data/HG008N_v6.3_hap1.cenSat.bed",
        "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/data/HG008N_v6.3_hap2.cenSat.bed",
    ],
    "HG008-T_v3.2": [
        "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/data/HG008T_v3.2.hap1.cenSat.bed",
        "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/data/HG008T_v3.2.hap2.cenSat.bed",
    ],
}
