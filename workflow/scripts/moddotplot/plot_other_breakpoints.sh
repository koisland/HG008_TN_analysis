#!/bin/bash

set -euo pipefail

brkpts="${1}"
fa="${2}"
rfa="${3}"
rbam="${4}"
outdir="${5:-breakpt_mdp}"

mkdir -p "${outdir}"

for dir in "mdp" "modkit" "rm"; do
    mkdir -p "${outdir}/${dir}"
done

while read -r line; do
    region_fs=$(awk '{ print $1"_"$2"-"$3}' <(printf "${line}"))
    region=$(awk '{ print $1":"$2"-"$3}' <(printf "${line}"))
    region_renamed_tab=$(printf "${line}" | awk -v OFS="\t" '{ print "HG008-N_v6.3_"$1, $2, $3}')
    fa_subset="${outdir}/${region_fs}.fa"
    samtools faidx "${fa}" "${region}" -o "${fa_subset}"

    # ModDotPlot
    mdp_bed="${outdir}/mdp/${region_fs}/${region}.bed"
    if [[ ! -f "${mdp_bed}" ]]; then
        censtats self-ident \
        -i "${fa_subset}" \
        -x 2D \
        -w 5000 \
        -o "${outdir}/mdp/${region_fs}" \
        -t 70.0
    fi

    # Modkit
    methyl_bed="${outdir}/modkit/${region_fs}/pileup.bed"
    avg_methyl_bed="${outdir}/modkit/${region_fs}/avg_perc_cpg.bed"
    if [[ ! -f "${methyl_bed}" ]] || [[ ! -f "${avg_methyl_bed}" ]]; then
        modkit pileup "${rbam}" "${methyl_bed}" \
        --include-bed <(printf "${region_renamed_tab}") \
        --threads 8 \
        --reference "${rfa}" \
        --modified-bases 5mC \
        --combine-strands \
        --cpg

        python /project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/workflow/rules/CDR-Finder/workflow/scripts/calculate_windows.py \
        -b <(printf "${region_renamed_tab}") \
        -m "${methyl_bed}" | \
        awk -v OFS="\t" -v CHROM="${region}" '{ $1=CHROM; print}' > "${avg_methyl_bed}"
    fi

    # RepeatMasker
    rm_out="${outdir}/rm/${region_fs}/${region_fs}.fa.out"
    rm_bed="${outdir}/rm/${region_fs}/rm.bed"
    if [[ ! -f "${rm_out}" ]] || [[ ! -f "${rm_bed}" ]]; then
        RepeatMasker \
        -engine rmblast \
        -species human \
        -dir "${outdir}/rm/${region_fs}" \
        -qq \
        -pa 12 \
        "${fa_subset}"

        python /project/logsdon_shared/projects/HG008_TN/CenMAP_T-N_v3.2-v6.3/workflow/scripts/format_rm_sat_annot.py \
        -i <(awk -v OFS="\t" '{
            $1=$1;
            if ($1 == "SW" || $1 == "score" || $1 == "") {
                next;
            };
            match($5, ":(.+)-", starts)
            $6=$6+starts[1];
            $7=$7+starts[1];
            print
        }' "${rm_out}") > "${rm_bed}"
    fi

    outdir_plots="${outdir}/plots/${region_fs}"
    mkdir -p "${outdir_plots}"
    tracks="${outdir}/plots/${region_fs}/cenplot.yaml"
    if [[ ! -f "${tracks}" ]]; then
        sed -e "s|\"methyl\"|${avg_methyl_bed}|g" \
            -e "s|\"rm\"|${rm_bed}|g" \
            -e "s|\"ident\"|${mdp_bed}|g" \
            config/cenplot_moddotplot.yaml > "${tracks}"
        cenplot draw -t "${tracks}" -c "${region}" -d "${outdir_plots}"
    fi
done < "${brkpts}"
