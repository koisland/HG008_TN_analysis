#!/bin/bash

set -euo pipefail

wd=$(dirname $0)

infile="/project/logsdon_shared/projects/GIAB_HG008_TN/exp/moddotplot/pairs.csv"
breakpoints="/project/logsdon_shared/projects/GIAB_HG008_TN/exp/moddotplot/param_breakpoints.tsv"
colors="/project/logsdon_shared/projects/GIAB_HG008_TN/exp/moddotplot/param_colors.tsv"

while IFS= read -r line; do
    fa_1=$(echo "${line}"| cut -d, -f 1)
    fa_2=$(echo "${line}"| cut -d, -f 2)
    bname_1=$(basename "${fa_1}" .fa)
    bname_2=$(basename "${fa_2}" .fa)
    pair_id=$(echo "${bname_1}~${bname_2}" | sed 's/:/_/g')

    multifasta="${wd}/${pair_id}.fa"
    if [ -d "${pair_id}" ]; then
        continue
    fi
    cat "${fa_1}" "${fa_2}" > "${multifasta}"
    moddotplot static \
        --compare-only \
        -f "${multifasta}" \
        -o "${pair_id}" \
        -id 70.0 -w 5000 \
        --breakpoints $(cut -f 1 "${breakpoints}") \
        --colors $(cut -f 1 "${colors}")
done < "${infile}"
