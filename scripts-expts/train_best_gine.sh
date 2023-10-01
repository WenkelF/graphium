#!/bin/bash

graphium-train \
    model=gine architecture=largemix tasks=largemix training=largemix accelerator=gpu constants.datacache_path=../datacache/large-dataset/ architecture.gnn.depth=10 architecture.graph_output_nn.graph.out_dim=577 architecture.graph_output_nn.node.out_dim=219 constants.gnn_dim=511 constants.gnn_edge_dim=38 constants.norm=batch_norm predictor.optim_kwargs.lr=0.0015843132994724453 constants.gnn_dim=592 constants.gnn_edge_dim=41 \
    +datamodule.args.multiprocessing_context=fork \
    datamodule.args.persistent_workers=False \
    constants.datacache_path=../datacache/large-dataset/ trainer.trainer.precision=32 \
    constants.max_epochs=100 \
    trainer.model_checkpoint.dirpath=model_checkpoints/large-dataset/best_gine_upd/${now:%Y-%m-%d_%H-%M-%S}/ \
    datamodule.args.num_workers=6 \
    constants.name=best_large_data_gine \
    constants.wandb.project=pretraining \
    trainer.trainer.check_val_every_n_epoch=10 \
    constants.seed=43 \