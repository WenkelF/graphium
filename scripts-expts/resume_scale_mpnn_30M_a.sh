#!/bin/bash

graphium-train \
    --config-path=/home/frederik_valencediscovery_com/projects/graphium_hps/expts/configs/ \
    --config-name=config_mpnn_10M.yaml \
    datamodule.args.multiprocessing_context=fork \
    datamodule.args.persistent_workers=False \
    datamodule.args.num_workers=6 \
    trainer.trainer.precision=32 \
    constants.max_epochs=100 \
    constants.datacache_path=../datacache/large-dataset/ \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/scale_mpnn_30M/a/ \
    constants.entity=recursion \
    constants.name=scale_large_data_mpnn_30M_a \
    constants.wandb.entity=recursion \
    constants.wandb.project=graphium-scaling \
    trainer.trainer.check_val_every_n_epoch=10 \
    +architecture.mup_scale_factor=1.798 \
    +architecture.mup_base_path=mup/mpnn_100/base_shapes.yaml \
    +trainer.resume_from_checkpoint=model_checkpoints/large-dataset/scale_mpnn_30M/a/last.ckpt \