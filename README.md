# HG008-TN Analysis

## `data`
* `bed`
    * Centromere coordinates in normal and tumor assemblies.
* `fasta`
    * Centromere indexed fasta files.
* `paf`
    * Tumor to normal `paf` alignments and their inverse via `rustybam invert`
    * SafFire bedfile alignments.
* `karyotype_colors_sorted.tsv`
    * Karyotype colors.

## `plots`
* [`SVbyEye`](https://github.com/daewoooo/SVbyEye) plots.

```R
renv::init()
renv::restore()
```

```bash
Rscript plot_tn.R
```

## `plots_cenmap`
* Generated CenMAP plots.

Clone CenMAP.
```bash
git clone https://github.com/logsdon-lab/CenMAP.git --branch feature/non-normal-cens
cd CenMAP

conda env create --name cenmap -f env.yaml
conda activate cenmap
```

Symlink TN raw data to data/ont and data/hifi
```
data/ont/
├── HG008-N
│   ├── 03_13_24_R1041_GIAB_Normal_Pancreas_2.dorado_0.5.3_5mC_5hmC.bam
│   ├── 03_13_24_R1041_GIAB_Normal_Pancreas_3.dorado_0.5.3_5mC_5hmC.bam
│   └── 03_13_24_R1041_GIAB_Normal_Pancreas.dorado_0.5.3_5mC_5hmC.bam
└── HG008-T
    ├── 11_12_2024_R1041_HG008_3066.dorado_0.8.1_sup.5mC_5hmC.bam
    ├── HG008-T_UCSC_20231031_ONT-UL-R10.4.1_1_dorado-v0.4.3_sup4.2.0-5mCG-5hmCG.bam
    ├── HG008-T_UCSC_20231031_ONT-UL-R10.4.1_2_dorado-v0.4.3_sup4.2.0-5mCG-5hmCG.bam
    └── HG008-T_UCSC_20231031_ONT-UL-R10.4.1_3_dorado-v0.4.3_sup4.2.0-5mCG-5hmCG.bam
data/hifi/
├── HG008-N
│   ├── HG008-N-P_PacBio-Revio_m84039_240114_032308_s2.hifi_reads.bc2006.bam
│   ├── m84059_240304_183205_s3.hifi_reads.bam
│   └── m84059_240304_203144_s4.hifi_reads.bam
└── HG008-T
    ├── HG008-T_PacBio-Revio_m84039_240113_032943_s4.hifi_reads.bc2005.bam
    ├── HG008-T_PacBio-Revio_m84039_240114_012401_s1.hifi_reads.bc2005.bam
    ├── m84101_240226_212100_s2.hifi_reads.bam
    └── m84101_240226_232018_s3.hifi_reads.bam
```

Run CenMAP on T and N.
```bash
snakemake -np --configfile plots_cenmap --configfile config.yaml
```
