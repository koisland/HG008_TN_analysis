import argparse
import seaborn as sns
import polars as pl
import matplotlib.pyplot as plt
import matplotlib.patheffects as pe


# https://stackoverflow.com/a/63295846
def add_median_labels(ax: plt.Axes, fmt: str = ".1f") -> None:
    """Add text labels to the median lines of a seaborn boxplot.

    Args:
        ax: plt.Axes, e.g. the return value of sns.boxplot()
        fmt: format string for the median value
    """
    lines = ax.get_lines()
    boxes = [c for c in ax.get_children() if "Patch" in str(c)]
    start = 4
    if not boxes:  # seaborn v0.13 => fill=False => no patches => +1 line
        boxes = [c for c in ax.get_lines() if len(c.get_xdata()) == 5]
        start += 1
    lines_per_box = len(lines) // len(boxes)
    for median in lines[start::lines_per_box]:
        x, y = (data.mean() for data in median.get_data())
        # choose value depending on horizontal or vertical plot orientation
        value = x if len(set(median.get_xdata())) == 1 else y
        text = ax.text(
            x,
            y,
            f"{value:{fmt}}",
            ha="center",
            va="center",
            fontweight="bold",
            color="white",
        )
        # create median-colored border around white text for contrast
        text.set_path_effects(
            [
                pe.Stroke(linewidth=3, foreground=median.get_color()),
                pe.Normal(),
            ]
        )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", "--infiles", nargs="+", type=str)
    ap.add_argument("-l", "--labels", nargs="+", type=str)
    ap.add_argument("-o", "--outfile", type=str)
    ap.add_argument("-y", "--ylim_qv", type=float, default=60)
    args = ap.parse_args()

    dfs: list[pl.DataFrame] = []
    for infile, label in zip(args.infiles, args.labels, strict=True):
        df = pl.read_csv(infile, separator="\t", has_header=True).with_columns(
            label=pl.lit(label)
        )
        dfs.append(df)

    df_all = pl.concat(dfs)

    fig, ax = plt.subplots(layout="constrained", figsize=(8, 8))
    sns.boxplot(
        data=df_all,
        x="label",
        y="QV",
        hue="label",
        order=args.labels,
        ax=ax,
        showfliers=False,
    )
    sns.stripplot(
        data=df_all,
        x="label",
        y="QV",
        hue="label",
        order=args.labels,
        linewidth=1,
        ax=ax,
    )
    add_median_labels(ax)
    ax.set_xlabel(None)
    ax.set_ylabel("QV (NucFlag)")
    ax.set_ylim(0, args.ylim_qv)
    for spine in ("top", "right"):
        ax.spines[spine].set_visible(False)

    fig.savefig(args.outfile, bbox_inches="tight", dpi=600)


if __name__ == "__main__":
    raise SystemExit(main())
