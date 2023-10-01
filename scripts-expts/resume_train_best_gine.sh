#!/bin/bash

graphium-train \
    model=gine architecture=largemix tasks=largemix training=largemix accelerator=gpu \
    +datamodule.args.multiprocessing_context=spawn \
    constants.datacache_path=../datacache/large-dataset/ architecture.gnn.depth=16 \
    architecture.gnn.out_dim=460 \
    constants.norm=layer_norm predictor.optim_kwargs.lr=0.0004 \
    constants.max_epochs=100 \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/best_gine/${now:%Y-%m-%d_%H-%M-%S}/ \
    datamodule.args.num_workers=6 \
    constants.name=resume_best_large_data_gine-v3 \
    constants.wandb.entity=wenkelf \
    constants.wandb.project=pretraining \
    trainer.trainer.check_val_every_n_epoch=4 \
    trainer.trainer.precision=32 \
    +trainer.resume_from_checkpoint=model_checkpoints/large-dataset/best_gine/last.ckpt \
    constants.seed=44 \