#!/bin/bash
#SBATCH --gres=gpu:v100l:1       # Request GPU "generic resources"
#SBATCH --cpus-per-task=3  # Refer to cluster's documentation for the right CPU/GPU ratio
#SBATCH --mem=32000M       # Memory proportional to GPUs: 32000 Cedar, 47000 Béluga, 64000 Graham.
#SBATCH --time=12:00:00     # DD-HH:MM:SS
#SBATCH --output=/home/ganesh/projects/def-nilanjan/ganesh/crnn_warmup_logs/%j.out

EXP_NUM=435
date +%c
echo "Running Experiment $EXP_NUM"
module load StdEnv/2020 tesseract/4.1.0
source /home/ganesh/projects/def-nilanjan/ganesh/ocr_bb_calls/bin/activate
cd /home/ganesh/projects/def-nilanjan/ganesh/Gradient-Approx-to-improve-OCR
DATA_PATH="$SLURM_TMPDIR/data"
DATASET_NAME="gcp_textareas"
if [ ! -d $DATA_PATH ]
then
	echo "Extraction started"
	cp "/home/ganesh/projects/def-nilanjan/ganesh/datasets/gcloud_vision/exp249_prep/$DATASET_NAME.zip" $SLURM_TMPDIR/
	cd $SLURM_TMPDIR
	unzip $DATASET_NAME.zip >> /dev/null
	# unzip $DATASET_NAME.zip -d $DATASET_NAME >> /dev/null

	echo "Dataset unzipped"
	mv $DATASET_NAME data
else
	echo "Dataset exists"
fi

cd /home/ganesh/projects/def-nilanjan/ganesh/Gradient-Approx-to-improve-OCR
BATCH_SIZE=64
EPOCH=200
CRNN_MODEL_PATH="/home/ganesh/scratch/experiment_$EXP_NUM/crnn_warmup/crnn_model"
TB_LOGS_PATH="/home/ganesh/scratch/experiment_$EXP_NUM/tb_logs"
CKPT_PATH='/home/ganesh/scratch/experiment_11/crnn_warmup/crnn_model_6'
mkdir -p $TB_LOGS_PATH $CRNN_MODEL_PATH
# tensorboard --logdir=$TB_LOGS_PATH --host 0.0.0.0 &
echo "Running training script"
python -u train_crnn.py --batch_size $BATCH_SIZE --epoch $EPOCH --crnn_model_path $CRNN_MODEL_PATH --dataset pos --tb_logs_path $TB_LOGS_PATH --data_base_path $SLURM_TMPDIR # --train_subset 100 --val_subset 100
#--minibatch_subset random 
# --ckpt_path $CKPT_PATH --start_epoch 6
date +%c