#!/bin/bash

graphium-train \
    model=gated_gcn architecture=largemix tasks=largemix training=largemix accelerator=gpu constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 architecture.gnn.depth=10 architecture.graph_output_nn.graph.out_dim=923 architecture.graph_output_nn.node.out_dim=223 constants.gnn_dim=303 constants.gnn_edge_dim=108 constants.norm=layer_norm predictor.optim_kwargs.lr=0.002692167197676275 constants.gnn_dim=395 constants.gnn_edge_dim=139 \
    +datamodule.args.multiprocessing_context=fork \
    datamodule.args.persistent_workers=False \
    constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 \
    constants.max_epochs=100 \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/best_gated_upd/${now:%Y-%m-%d_%H-%M-%S}/ \
    datamodule.args.num_workers=6 \
    constants.name=best_large_data_gated_gcn \
    constants.wandb.project=pretraining \
    trainer.trainer.check_val_every_n_epoch=10 \
    constants.seed=43 \