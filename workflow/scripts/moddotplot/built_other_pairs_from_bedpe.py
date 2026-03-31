import os
import sys
import subprocess


def main():
    bedpe = sys.argv[1]
    t_fa = sys.argv[2]
    n_fa = sys.argv[3]
    outdir_fa = sys.argv[4]

    with open(bedpe, "rt") as fh:
        for line in fh:
            t_chrom, t_st, t_end, n_chrom, n_st, n_end = line.strip().split()
            tn_id = f"{t_chrom}_{n_chrom}"
            
            t_coords = f"{t_chrom}:{t_st}-{t_end}"
            n_coords = f"{n_chrom}:{n_st}-{n_end}"

            t_subset_fa = os.path.join(outdir_fa, f"{t_coords.replace(":", "_")}.fa")
            n_subset_fa = os.path.join(outdir_fa, f"{n_coords.replace(":", "_")}.fa")

            subprocess.run(
                [
                "samtools", "faidx", t_fa, t_coords, "-o", t_subset_fa
                ],
                check=True
            )
            subprocess.run(
                [
                "samtools", "faidx", n_fa, n_coords, "-o", n_subset_fa
                ],
                check=True
            )
            print(tn_id, t_subset_fa, n_subset_fa, sep=",")

if __name__ == "__main__":
    raise SystemExit(main())
