import argparse

import polars as pl
import seaborn as sns
import matplotlib.patheffects as pe

from matplotlib.axes import Axes
from matplotlib.colors import rgb2hex

PALETTE_NUCFLAG = {
    "collapse": "0,255,0",
    "correct": "206,206,206",
    "deletion": "248,244,255",
    "dinucleotide": "0,49,83",
    "false_dup": "0,0,255",
    "het_or_mismap": "121,133,100",
    "homopolymer": "236,236,0",
    "insertion": "128,0,128",
    "low_quality": "0,128,0",
    "misjoin": "191,26,46",
    "mismatch": "255,128,0",
    "other_repeat": "155,118,83",
    "scaffold": "0,0,0",
    "simple_repeat": "255,0,128",
    "softclip": "0,255,255",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", "--infiles", nargs="+", type=str)
    ap.add_argument("-l", "--labels", nargs="+", type=str)
    ap.add_argument("-p", "--outfile_plot", type=str)
    ap.add_argument("-t", "--outfile_tsv", type=str)
    args = ap.parse_args()
    
    dfs = []
    for file, label in zip(args.infiles, args.labels):
        df = (
            pl.scan_csv(file, separator="\t", has_header=True)
            .with_columns(length=pl.col("chromEnd")-pl.col("chromStart"))
            .drop("chromStart", "chromEnd", "status")
            .unpivot(index=["#chrom", "length"], variable_name="type", value_name="perc")
            .with_columns(label=pl.lit(label))
            .collect()
        )
        dfs.append(df)

    df = (
        pl.concat(dfs)
        .with_columns(length=pl.col("length") * (pl.col("perc") / 100.0))
        .group_by(["label", "type"])
        .agg(pl.col("length").sum().cast(pl.UInt64))
        .with_columns(
            perc=(pl.col("length") / pl.col("length").sum().over("label")) * 100
        )
    )

    g = sns.catplot(
        df.filter(pl.col("type").ne(pl.lit("correct"))),
        x="type",
        y="length",
        hue="label",
        kind="bar",
        height=8,
        aspect=2.0,
        legend="full",
        hue_order=args.labels,
    )
    for ax in g.axes.ravel():
        ax: Axes
        for cont in ax.containers:
            ax.bar_label(cont, fmt=lambda x: f"{x / 1_000_000:.1f}")
        
        ax.set_xlabel("NucFlag call")
        ax.set_ylabel("Length (Mbp)")
        ax.yaxis.set_major_formatter(lambda x, pos: f"{x / 1_000_000:.1f}")

        for label in ax.get_xticklabels():
            label.set_rotation(45)
            label.set_horizontalalignment("right")
            rgb_color = PALETTE_NUCFLAG.get(label.get_text())
            if rgb_color:
                hexcode = rgb2hex([int(c) / 255.0 for c in rgb_color.split(",")])
                label.set_color(hexcode)
                label.set_path_effects(
                    [
                        pe.Stroke(linewidth=0.5, foreground="black"),
                        pe.Normal(),
                    ]
                )

    sns.move_legend(
        g,
        loc="upper right",
        bbox_to_anchor=(1.0, 0.95),
        title="Version",
        handlelength=1.0,
        handleheight=1.0,
        borderaxespad=0,
        fancybox=False,
        frameon=False,
    )
    df.write_csv(args.outfile_tsv, separator="\t", include_header=True)
    g.savefig(args.outfile_plot, bbox_inches="tight", dpi=300)

if __name__ == "__main__":
    raise SystemExit(main())
