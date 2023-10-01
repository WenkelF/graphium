#!/usr/bin/env bash

## Name of your SLURM job
#SBATCH --job-name=run

## Files for logs: here we redirect stoout and sterr to the same file
#SBATCH --output=outputs/out_%j.out   # %x=job-name, %j=jobid, %a=array-id
#SBATCH --error=outputs/error_%j.out
#SBATCH --open-mode=append

## Time limit for the job
#SBATCH --time=120:00:00

## Partition to use,
#SBATCH --partition=a1001

set -e

source /home/frederik_valencediscovery_com/.bashrc

micromamba activate graphium_dev

graphium-train \
    --config-path=/home/frederik_valencediscovery_com/projects/graphium_hps/expts/configs/ \
    --config-name=config_mpnn_10M.yaml \
    datamodule.args.multiprocessing_context=fork \
    datamodule.args.persistent_workers=False \
    datamodule.args.num_workers=6 \
    trainer.trainer.precision=32 \
    constants.max_epochs=100 \
    constants.datacache_path=../datacache/large-dataset/ \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/scale_mpnn_100M/44/ \
    +trainer.model_checkpoint.save_top_k=1 \
    +trainer.model_checkpoint.monitor=loss/val \
    constants.entity=recursion \
    constants.name=scale_large_data_mpnn_100M_a \
    constants.wandb.entity=recursion \
    constants.wandb.project=graphium-scaling \
    trainer.trainer.check_val_every_n_epoch=1 \
    +architecture.mup_scale_factor=3.38 \
    +architecture.mup_base_path=mup/mpnn_100/base_shapes.yaml \
    datamodule.args.batch_size_inference=1024 \
    datamodule.args.batch_size_training=1024 \
    +trainer.trainer.accumulate_grad_batches=2 \
    constants.seed=44 \