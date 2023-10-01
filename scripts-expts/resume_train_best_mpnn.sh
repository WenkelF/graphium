#!/bin/bash

graphium-train \
    model=mpnn architecture=largemix tasks=largemix training=largemix accelerator=gpu \
    +datamodule.args.multiprocessing_context=spawn \
    constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 \
    architecture.gnn.depth=16 architecture.gnn.hidden_dims_edges=96 architecture.gnn.out_dim=192 \
    constants.norm=layer_norm predictor.optim_kwargs.lr=0.0004 \
    constants.max_epochs=100 \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/best_mpnn/${now:%Y-%m-%d_%H-%M-%S}/ \
    datamodule.args.num_workers=6 \
    constants.name=best_large_data_mpnn \
    constants.wandb.entity=wenkelf \
    constants.wandb.project=pretraining \
    trainer.trainer.check_val_every_n_epoch=4 \
    trainer.trainer.precision=32 \
    +trainer.resume_from_checkpoint=model_checkpoints/large-dataset/best_mpnn/last.ckpt \
    constants.seed=44 \