library(SVbyEye)
library(dplyr)
library(ggplot2)
library(readr)
library(rtracklayer)
library(stringr)

## Read in PAF
df_paf <- readPaf(
  paf.file = "../../data/paf/HG008-T.paf",
  include.paf.tags = TRUE, restrict.paf.tags = "cg"
)
df_colors <- readr::read_tsv("../../data/karyotype_colors_sorted.tsv")

df_paf <- df_paf %>%
  mutate(
    chrom=str_extract(t.name, "chr[0-9XYM]+")
  ) %>%
  left_join(
    df_colors, by="chrom"
  ) %>%
  filter(aln.len > 1000000)

colors <- df_paf$color
names(colors) <- df_paf$t.name

gr_T_cens <- import.bed("../../data/bed/HG008-T_complete_cens.bed")
gr_T_cens$region <- "Centromere"
cens_palette <- c("Centromere" = "red")

outdir = "plots"
ifelse(
  !dir.exists(file.path(outdir)),
   dir.create(file.path(outdir)),
   "Directory Exists"
)

for (i in unique(df_paf$q.name)) {
  plt <- plotMiro(
    paf.table = df_paf %>% filter(q.name == i),
    color.by = "t.name",
    color.palette = colors,
    outline.alignments = TRUE
  )
  addAnnotation(
    plt, gr_T_cens,
    fill.by = "region",
    coordinate.space = "query",
    color.palette = cens_palette,
    shape = "rectangle"
  )
  ggsave(paste0(outdir, "/", i, ".png"), width=16, height=8, dpi=600)
}

