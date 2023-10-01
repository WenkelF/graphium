#!/bin/bash

graphium-train \
    model=gated_gcn architecture=largemix tasks=largemix training=largemix accelerator=gpu \
    +datamodule.args.multiprocessing_context=spawn \
    constants.datacache_path=../datacache/large-dataset/ \
    trainer.trainer.precision=32 architecture.gnn.depth=8 \
    architecture.gnn.hidden_dims_edges=256 architecture.gnn.out_dim=449 \
    constants.max_epochs=20 constants.norm=batch_norm predictor.optim_kwargs.lr=0.0002 \
    constants.max_epochs=100 \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/best_gated_gcn/${now:%Y-%m-%d_%H-%M-%S}/ \
    datamodule.args.num_workers=6 \
    constants.name=best_large_data_gated_gcn \
    constants.wandb.entity=wenkelf \
    constants.wandb.project=pretraining \
    trainer.trainer.check_val_every_n_epoch=4 \
    trainer.trainer.precision=32 \
    +trainer.resume_from_checkpoint=model_checkpoints/large-dataset/best_gated_gcn/last.ckpt \
    constants.seed=44 \