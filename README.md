# HG008-TN Analysis

## Usage

### Run CenMAP
Set up data.
```bash
bash workflow/scripts/cenmap/setup_data.sh
```

Clone repo.
```bash
git clone git@github.com:logsdon-lab/CenMAP.git
cd CenMAP
git checkout c439499ca94227685e074256a102673f49eea400
```

Modify yaml to match data locations.
* `/project/logsdon_shared/data/NIST_GIAB_HG008/assemblies/`
* `data/raw_data/(hifi|ont)`

Run CenMAP
```bash
snakemake -p \
    --configfile ../config/config_hg008.yaml \
    --workflow-profile workflow/profiles/lpc_all \
    -j 50
```

### Other analyses
* NucFlag
* ModDotPlot
* SVbyEye

> [!NOTE]
> All paths are hardcoded for UPenn LPC.

```bash
cd ..
snakemake -p --sdm conda apptainer -c 4 --workflow-profile CenMAP/workflow/profiles/default/ -n
```

#### Build SVbyEye docker
```bash
docker build . -t svbyeye:latest -f workflow/envs/svbyeye.dockerfile
# Convert to singularity image
sudo singularity build svbyeye.sif docker-daemon://svbyeye:latest
```
