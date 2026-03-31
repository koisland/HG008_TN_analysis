import argparse

import numpy as np
import polars as pl
import seaborn as sns
import intervaltree as it
import matplotlib.patheffects as pe

from typing import Counter
from matplotlib.axes import Axes
from collections import defaultdict
from matplotlib.colors import rgb2hex
from matplotlib.patches import Patch
from matplotlib.figure import Figure


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-i", "--infile_nucflag", type=str, help="input nucflag", required=True
    )
    ap.add_argument(
        "-c", "--infile_censat", type=str, help="input censat", required=True
    )
    ap.add_argument(
        "-p", "--output_plot", type=str, help="output plot", default="out.png"
    )
    ap.add_argument(
        "-t", "--output_tsv", type=str, help="output tsv", default="out.tsv"
    )
    args = ap.parse_args()

    df_calls = (
        pl.scan_csv(args.infile_nucflag, separator="\t", has_header=True)
        .filter(pl.col("name").ne(pl.lit("correct")))
        .collect()
    )
    itree_calls: defaultdict[str, it.IntervalTree] = defaultdict(it.IntervalTree)
    for row in df_calls.iter_rows(named=True):
        try:
            itree_calls[row["#chrom"]].add(
                it.Interval(row["chromStart"], row["chromEnd"], row["name"])
            )
        except ValueError:
            continue

    palette_nucflag = {
        name: rgb2hex(tuple(int(c) / 255.0 for c in item_rgb.split(",")))
        for name, item_rgb in df_calls.select("name", "itemRgb").unique().iter_rows()
    }

    df_infile_censat = pl.read_csv(
        args.infile_censat,
        separator="\t",
        comment_prefix="track",
        has_header=False,
        new_columns=[
            "#chrom",
            "chromStart",
            "chromEnd",
            "name",
            "score",
            "strand",
            "thickStart",
            "thickEnd",
            "itemRgb",
        ],
    ).with_columns(
        name=pl.col("name").str.extract(r"^(.*?)\(").fill_null(pl.col("name")),
        length=pl.col("chromEnd") - pl.col("chromStart"),
    )
    palette_censat = {
        censat: rgb2hex(tuple(int(c) / 255.0 for c in item_rgb.split(",")))
        for censat, item_rgb in df_infile_censat.select("name", "itemRgb")
        .unique()
        .sort(by="name")
        .iter_rows()
    }

    censat_total_bp = dict(
        df_infile_censat.group_by(["name"])
        .agg(length=pl.col("length").sum())
        .iter_rows()
    )
    rows = []
    for censat_type, df_censat_type in df_infile_censat.partition_by(
        ["name"], as_dict=True
    ).items():
        censat_type = censat_type[0]
        total_bp = censat_total_bp[censat_type]
        cnt_total_ovl_bp: Counter[str] = Counter()
        for row in df_censat_type.iter_rows(named=True):
            chrom, st, end = row["#chrom"], row["chromStart"], row["chromEnd"]
            ovl_w_nucflag = itree_calls[chrom].overlap(st, end)
            if not ovl_w_nucflag:
                continue
            for itv in ovl_w_nucflag:
                call = itv.data
                # trim
                ist = np.clip(itv.begin, st, end)
                iend = np.clip(itv.end, st, end)
                ovl_len = int(iend - ist)
                cnt_total_ovl_bp[call] += ovl_len

        rows.extend(
            (censat_type, total_bp, call, total_call_bp)
            for call, total_call_bp in cnt_total_ovl_bp.items()
        )
    df_censat_ovl = pl.DataFrame(
        data=rows,
        orient="row",
        schema=["censat", "total_bp_censat", "nucflag", "total_bp_nucflag"],
    ).with_columns(
        prop=((pl.col("total_bp_nucflag") / pl.col("total_bp_censat")) * 100.0).round(1)
    )

    g = sns.catplot(
        df_censat_ovl,
        kind="bar",
        x="nucflag",
        y="prop",
        hue="censat",
        col="censat",
        col_wrap=4,
        col_order=palette_censat.keys(),
        palette=palette_censat,
        legend=None,
        height=2.5,
        aspect=3.0,
    )
    g.set_titles("{col_name}")
    for ax in g.axes:
        ax: Axes
        ax.set_xlabel(None)
        ax.set_ylabel(None)

        title = ax.get_title()
        bp_censat_type = censat_total_bp[title]
        mbp_censat_type = round(bp_censat_type / 1_000_000, 2)
        ax.set_title(
            f"{title} ({mbp_censat_type} Mbp)",
            color=palette_censat[title],
            path_effects=[
                pe.Stroke(linewidth=1.0, foreground="black"),
                pe.Normal(),
            ],
        )

        for cont in ax.containers:
            ax.bar_label(cont)

        for label in ax.get_xticklabels():
            label.set_rotation(45)
            label.set_horizontalalignment("right")
            color = palette_nucflag.get(label.get_text())
            if color:
                label.set_color(palette_nucflag[label.get_text()])
                label.set_path_effects(
                    [
                        pe.Stroke(linewidth=0.5, foreground="black"),
                        pe.Normal(),
                    ]
                )
    
    # TODO: Aggregate total.
    
    fig: Figure = g.figure
    fig.legend(
        title=None,
        handles=[
            Patch(edgecolor="black", facecolor=color)
            for censat, color in palette_censat.items()
        ],
        loc="center left",
        bbox_to_anchor=(1.0, 0.5),
        labels=palette_censat.keys(),
        handlelength=1.0,
        handleheight=1.0,
        borderaxespad=0,
        fancybox=False,
        frameon=False,
    )
    g.set_xlabels("NucFlag call")
    g.set_ylabels("Proportion of censat (%)")
    g.savefig(args.output_plot, dpi=150)
    df_censat_ovl.write_csv(args.output_tsv, include_header=True, separator="\t")


if __name__ == "__main__":
    raise SystemExit(main())
