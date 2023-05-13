#!/bin/bash
#SBATCH --gres=gpu:v100l:1       # Request GPU "generic resources"
#SBATCH --cpus-per-task=3  # Refer to cluster's documentation for the right CPU/GPU ratio
#SBATCH --mem=8000       # Memory proportional to GPUs: 32000 Cedar, 47000 B�luga, 64000 Graham.
#SBATCH --time=6:30:00     # DD-HH:MM:SS
#SBATCH --output=/home/ganesh/projects/def-nilanjan/ganesh/nn_area_logs/%j.out

EXP_NUM=504
echo "Running Experiment $EXP_NUM"

module load StdEnv/2020 tesseract/4.1.0
source /home/ganesh/projects/def-nilanjan/ganesh/ocr_bb_calls/bin/activate

#wandb disabled
#wandb offline
wandb login $WANDB_API_KEY
DATASET_NAME="vgg"
DATA_PATH="$SLURM_TMPDIR/$DATASET_NAME"
if [ ! -d $DATA_PATH ]
then
    echo "VGG Dataset extraction started"
    cp /home/ganesh/projects/def-nilanjan/ganesh/datasets/$DATASET_NAME.zip $SLURM_TMPDIR/
    cd $SLURM_TMPDIR
    unzip $DATASET_NAME.zip >> /dev/null
    echo "$DATASET_NAME Dataset extracted"
else
    echo "$DATASET_NAME Dataset exists"
fi
cd /home/ganesh/projects/def-nilanjan/ganesh/Gradient-Approx-to-improve-OCR
BATCH_SIZE=64
EPOCH=10
EXP_BASE_PATH="/home/ganesh/scratch/experiment_$EXP_NUM/"
CRNN_MODEL_PATH="/home/ganesh/projects/def-nilanjan/ganesh/experiment_artifacts/experiment_8/crnn_warmup/crnn_model_29"
TB_LOGS_PATH="/home/ganesh/scratch/experiment_$EXP_NUM/tb_logs"
CKPT_BASE_PATH="/home/ganesh/scratch/experiment_$EXP_NUM/ckpts"
CER_JSON_PATH="/home/ganesh/projects/def-nilanjan/ganesh/Gradient-Approx-to-improve-OCR/cer_data_utils/vgg_cers.json"
mkdir -p $TB_LOGS_PATH $CKPT_BASE_PATH
# tensorboard --logdir=$TB_LOGS_PATH --host 0.0.0.0 &
echo "Running training script"
python -u area_cli.py --batch_size $BATCH_SIZE --epoch $EPOCH --exp_id $EXP_NUM --exp_base_path $EXP_BASE_PATH --crnn_model  $CRNN_MODEL_PATH --data_base_path $DATA_PATH --exp_name vgg_rangeCER_4_test --minibatch_subset rangeCER --minibatch_subset_prop 0.93 --inner_limit 1  --cers_ocr_path $CER_JSON_PATH # --train_subset_size 100 --val_subset_size 100 # --val_subset_size 10000 # --minibatch_subset_prop 0.93 --minibatch_subset rangeCER  # --std 0 #--inner_limit_skip 
# --minibatch_subset_prop 0.5 --label_impute
