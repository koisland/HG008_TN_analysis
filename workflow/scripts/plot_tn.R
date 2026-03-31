library(SVbyEye)
library(dplyr)
library(ggplot2)
library(readr)
library(rtracklayer)
library(stringr)
library(optparse)

parser <- OptionParser()
parser <- add_option(parser, c("-p", "--paf"), help="PAF file")
parser <- add_option(parser, c("-c", "--colors"), help="Colors")
parser <- add_option(parser, c("-r", "--bed_reference"), help="Bed reference")
parser <- add_option(parser, c("-q", "--bed_query"), help="Bed query")
parser <- add_option(parser, c("--reference_label"), default="Reference", help="Reference label")
parser <- add_option(parser, c("--reference_color"), default="blue", help="Reference color")
parser <- add_option(parser, c("--query_label"), default="Query", help="Query label")
parser <- add_option(parser, c("--query_color"), default="red", help="Query color")
parser <- add_option(parser, c("-o", "--output_dir"), help="Output directory")
args <- parse_args(parser)

# args <- list(
#   "paf" = "results/sv_by_eye/HG008-N_HG008-T_inverted.paf",
#   "colors" = "/project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/exp/HG008_TN_analysis/config/karyotype_colors_sorted.tsv",
#   "output_dir" = "out",
#   "bed_query" = "results/sv_by_eye/HG008-N_cens.bed",
#   "bed_reference" = "results/sv_by_eye/HG008-T_cens.bed"
# )
## Read in PAF
df_paf <- readPaf(
  paf.file = args$paf,
  include.paf.tags = TRUE, restrict.paf.tags = "cg"
)
df_colors <- readr::read_tsv(args$colors, show_col_types=FALSE)

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

query_label <- args$query_label 
gr_query <- import.bed(args$bed_query)
gr_query$sample <- query_label
query_palette <- list()
query_palette[[query_label]] <- args$query_color

reference_label <- args$reference_label
gr_ref <- import.bed(args$bed_reference)
gr_ref$sample <- reference_label
reference_palette <- list()
reference_palette[[reference_label]] <- args$reference_color

outdir = args$output_dir
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
  plt1 = addAnnotation(
    ggplot.obj = plt,
    annot.gr = gr_query,
    fill.by = "sample",
    coordinate.space = "query",
    color.palette = query_palette,
    shape = "rectangle"
  )
  addAnnotation(
    plt1, gr_ref,
    fill.by = "sample",
    coordinate.space = "target",
    color.palette = reference_palette,
    shape = "rectangle"
  )

  ggsave(paste0(outdir, "/", i, ".png"), width=16, height=8, dpi=600)
}

