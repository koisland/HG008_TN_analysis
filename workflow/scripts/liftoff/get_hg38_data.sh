#!/bin/bash

set -euo pipefail

# Get assembly
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_48/GRCh38.p14.genome.fa.gz
gunzip GRCh38.p14.genome.fa.gz

# Get gene annotations
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_48/gencode.v48.annotation.gff3.gz
gunzip gencode.v48.annotation.gff3.gz
