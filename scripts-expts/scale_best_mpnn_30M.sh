#!/bin/bash

graphium-train \
    model=mpnn architecture=largemix tasks=largemix training=largemix accelerator=gpu constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 architecture.gnn.depth=16 +architecture.gnn.layer_kwargs.mlp_expansion_ratio=1 architecture.graph_output_nn.graph.out_dim=653 architecture.graph_output_nn.node.out_dim=84 constants.gnn_dim=454 constants.gnn_edge_dim=35 constants.norm=layer_norm predictor.optim_kwargs.lr=0.002738489058978671 constants.gnn_dim=337 constants.gnn_edge_dim=22 \
    +datamodule.args.multiprocessing_context=fork \
    datamodule.args.persistent_workers=False \
    constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 \
    constants.max_epochs=100 \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/scale_best_mpnn_30M/v/ \
    datamodule.args.num_workers=6 \
    constants.name=scale_large_data_mpnn_30M \
    constants.wandb.project=pretraining \
    trainer.trainer.check_val_every_n_epoch=10 \
    +architecture.mup_scale_factor=1.798 \
    +architecture.mup_base_path=mup/mpnn_100/base_shapes.yaml \
    datamodule.args.batch_size_inference=1024 \
    datamodule.args.batch_size_training=1024 \
    +trainer.trainer.accumulate_grad_batches=2 \