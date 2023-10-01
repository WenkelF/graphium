#!/bin/bash

graphium-train \
    model=mpnn architecture=largemix tasks=largemix training=largemix accelerator=gpu constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 +architecture.gnn.layer_kwargs.mlp_expansion_ratio=2 architecture.gnn.depth=16 architecture.gnn.layer_kwargs.mlp_expansion_ratio=1 architecture.graph_output_nn.graph.out_dim=653 architecture.graph_output_nn.node.out_dim=84 constants.gnn_dim=454 constants.gnn_edge_dim=35 constants.norm=layer_norm predictor.optim_kwargs.lr=0.002738489058978671 constants.gnn_dim=337 constants.gnn_edge_dim=22 \
    +datamodule.args.multiprocessing_context=fork \
    datamodule.args.persistent_workers=False \
    constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 \
    constants.max_epochs=100 \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/best_mpnn_upd/${now:%Y-%m-%d_%H-%M-%S}/ \
    datamodule.args.num_workers=6 \
    constants.name=best_large_data_mpnn \
    constants.wandb.project=pretraining \
    trainer.trainer.check_val_every_n_epoch=10 \
    constants.seed=43 \