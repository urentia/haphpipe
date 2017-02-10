#! /bin/bash

SN="haphpipe_predicthaplo.sh"

if [[ -n "$SLURM_ARRAY_TASK_ID" ]]; then
    # This is an array job
    [[ ! -n "$samplist" ]] && echo "Array job requires sample list as environment variable \"\$samplist\"" && exit 1
    samp=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplist)
else
    [[ -n "$1" ]] && samp="$1"
fi

[[ -z "$samp" ]] && echo "\"\$samp\" was not provided" && exit 1
[[ -d "$samp" ]] && echo "Directory \"$samp\" was not found" && exit 1

module unload python
module load miniconda3
source activate haphpipe

module load PredictHaplo

echo "[---$SN---] ($(date)) Starting $SN"

#--- Start the timer
t1=$(date +"%s")

for method in "trim" "bless"; do
    echo "[---$SN---] ($(date)) Stage: PredictHaplo, $method"
    mkdir -p $samp/10_predicthaplo/${method}
    
    hp_haplotype predict_haplo --ncpu $(nproc) \
        --alignment $samp/09_fixed/${method}/final.bam \
        --ref_fa $samp/09_fixed/${method}/consensus.fasta \
        --outdir $samp/10_predicthaplo/${method} \
        --min_interval 200
done

#---Complete job
t2=$(date +"%s")
diff=$(($t2-$t1))
echo "[---$SN---] ($(date)) $(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
echo "[---$SN---] ($(date)) $SN COMPLETE."
