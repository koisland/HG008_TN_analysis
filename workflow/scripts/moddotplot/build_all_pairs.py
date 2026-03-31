from collections import defaultdict
from typing import NamedTuple
import sys
import glob
import os

T_SM = "HG008-T_v3.2"
N_SM = "HG008-N_v6.3"
CHROMS = set([f"chr{i}" for i in (*range(1, 23), "X", "Y")])

class ContigSummary(NamedTuple):
    fasta: str
    sample: str
    chroms: list[str]
    hap: str

def main():
    # /project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/results/8-humas_annot/seq
    fasta_cen_dir = sys.argv[1]
    fasta_files = glob.glob(os.path.join(fasta_cen_dir, "*.fa"))
    all_categ_fasta_files: defaultdict[str, defaultdict[str, defaultdict[str, list[ContigSummary]]]] = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for fasta in fasta_files:
        bname = os.path.splitext(os.path.basename(fasta))[0]
        if bname.startswith(T_SM):
            sample = T_SM
            bname = bname.replace(f"{sample}_", "")
            chroms_hap, coords = bname.split(":")
            chroms, hap = chroms_hap.rsplit("_", 1)
            chroms = set(chroms.split("_")).intersection(CHROMS)
            summary = ContigSummary(fasta=fasta, sample=sample, chroms=sorted(chroms), hap=hap)
        elif bname.startswith(N_SM):
            sample = N_SM
            bname = bname.replace(f"{sample}_", "")
            chroms_hap, coords = bname.split(":")
            chroms, hap = chroms_hap.rsplit("_", 1)
            chroms = set(chroms.split("_")).intersection(CHROMS)
            summary = ContigSummary(fasta=fasta, sample=sample, chroms=sorted(chroms), hap=hap)
        else:
            summary = None
        if not summary:
            continue

        for chrom in chroms:
            all_categ_fasta_files[summary.sample][summary.hap][chrom].append(summary)

    rows = set()
    for hap, hap_items in all_categ_fasta_files[N_SM].items():
        for fasta in (
            fasta
            for chrom, chrom_items in hap_items.items()
            for fasta in chrom_items
        ):
            for chrom in fasta.chroms:
                tumor_fasta = all_categ_fasta_files[T_SM][hap][chrom]
                for tfasta in tumor_fasta:
                    pair_id = "_".join([fasta.sample, fasta.hap, "_".join(fasta.chroms), tfasta.sample, tfasta.hap, "_".join(tfasta.chroms)])
                    rows.add(
                        (pair_id, fasta.fasta, tfasta.fasta)
                    )

    for row in rows:
        print(
            ",".join(row),
            file=sys.stdout
        )


if __name__ == "__main__":
    raise SystemExit(main())
