import subprocess
import polars as pl
import matplotlib.pyplot as plt


# https://www.statology.org/benjamini-hochberg-procedure/
def main():
    infile = "/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_pair.bed.gz"
    outfile = "/project/logsdon_shared/projects/GIAB_HG008_TN/exp/dmr/data/HG008-TN_dmr_pair_bh.bed"
    df = pl.read_csv(infile, separator="\t")
    nrows = df.shape[0]

    FDR = 0.05
    PVAL_FILTER = 0.01
    df = (
        df.lazy()
        .filter(pl.col("map_pvalue") < PVAL_FILTER)
        .with_columns(
            map_pvalue_rank=pl.col("map_pvalue").rank()
        )
        .with_columns(
            pl.col("map_pvalue_rank") / pl.col("map_pvalue_rank").min()
        )
        .with_columns(
            bh_crit_value=(pl.col("map_pvalue_rank") / df.shape[0]) * FDR
        )
        .collect()
    )

    nrows_after_init_filter = df.shape[0]
    print(f"Removed {nrows - nrows_after_init_filter} after p-value filter {PVAL_FILTER}")
    
    # plt.plot(df["effect_size"], -df["map_pvalue"].log10())
    # plt.savefig("effect_size-vs-log_map_pvalue.png")
    # plt.clf()

    df = df.filter(
        pl.col("map_pvalue") < pl.col("bh_crit_value")
    )
    nrows_after_bh = df.shape[0]

    print(f"Removed {nrows_after_init_filter - nrows_after_bh} after BH with FDR of {FDR * 100}%")

    df.write_csv(outfile, separator="\t")

    plt.plot(df["effect_size"], -(df["map_pvalue"].log10()), 'ro')
    plt.savefig("effect_size-vs-log_map_pvalue_bh.png")

    subprocess.run(["bgzip", outfile], check=True)
    subprocess.run(["tabix", "-p", "bed", f"{outfile}.gz"], check=True)

if __name__ == "__main__":
    raise SystemExit(main())
