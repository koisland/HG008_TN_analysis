#!/bin/bash

set -euo pipefail

IN_DATA_DIR="/project/logsdon_shared/data/NIST_GIAB_HG008"
OUT_DATA_DIR=$(realpath "data/raw_data")
DTYPES=(
    hifi
    ont
)
for dtype in "${DTYPES[@]}"; do
    out_data_dir_dtype="${OUT_DATA_DIR}/${dtype}"
    mkdir -p "${out_data_dir_dtype}"
    if [[ ${dtype} == "ont" ]]; then
        normal_dir=HG008-N-P
    else
        normal_dir=HG008-N
    fi
    ln -s "${IN_DATA_DIR}/${dtype}/${normal_dir}" "${out_data_dir_dtype}/HG008-N_v6.3"
    ln -s "${IN_DATA_DIR}/${dtype}/HG008-T" "${out_data_dir_dtype}/HG008-T_v3.2"
done
