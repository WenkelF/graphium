#!/bin/bash

graphium-train \
    architecture=largemix \
    tasks=largemix \
    training=largemix \
    model=mpnn \
    accelerator=gpu \
    constants.max_epochs=10 \
    constants.wandb.project="hp_search" \
    constants.data_dir="../data/graphium/large-dataset/" \
    constants.datacache_path="../datacache/large-dataset/" \
    architecture.gnn.depth=12 \
    architecture.gnn.out_dim=222 \
    architecture.gnn.hidden_dims_edges=111 \
    # trainer.trainer.precision=32 \
    # constants.norm=batch_norm \
    # architecture.gnn.layer_kwargs.aggregation_method=["sum] \

# graphium-train \
#     accelerator=gpu \
#     model=gcn \
#     constants.max_epochs=10 \
#     constants.wandb.project="hp_search" \
#     constants.data_dir="../data/graphium/small-dataset/" \
#     constants.datacache_path="../datacache/dummy-dataset/" \