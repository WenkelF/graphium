# Contribute to goli

## Structure of the code

The code is built to rapidly iterate on different architectures of neural networks (NN) and graph neural networks (GNN) with Pytorch. The main focus of this work is molecular tasks, and we use the package `rdkit` to transform molecular SMILES into graphs.

### data_parser

This folder contains tools that allow tdependenciesrent kind of molecular data files, such as `.csv` or `.xlsx` with SMILES data, or `.sdf` files with 3D data.

### dgl

This folder contains the code necessary for compatibility with the Deep Graph Library (DGL), and implements many state of the art GNN methods, such as GCN, GIN, MPNN and PNA.
It also contains major network architecture implemented for DGL (feed-forward, resnet, skip-connections, densenet), along with the DGL graph transformer for molecules.
**_I was thinking of removing most models to avoid having too much maintenance to do, since they either don't perform well on molecular tasks (GAT, RingGNN) or they are generalized by DGN (GCN, GIN, MPNN, PNA, GraphSage)_**.

### mol_utils

Different utilities for molecules, such as Smiles to adjacency graph transformer, molecular property extraction, atomic properties, bond properties, ...

**_The MolecularTransformer and AdjGraphTransformer come from ivbase, but I don't like them. I think we should replace them with something simpler and give more flexibility for combining one-hot embedding with physical properties embedding._**.

### trainer

The trainer contains the interface to the `pytorch-lightning` library, with `ModelWrapper` being the main class used for any NN model, either for regression or classification. It also contains some modifications to the logger and reporting from `pytorch-lightning` to enable more flexibility.

### utils

Any kind of utilities that can be used anywhere, including argument checkers and configuration loader

### visualization

Plot visualization tools

## Modifying the code

### Adding a new GNN layer

Any new GNN layer must inherit from the class `goli.dgl.dgl_layers.base_dgl_layer.BaseDGLLayer` and be implemented in the folder `goli/dgl/dgl_layers`, imported in the file `goli/dgl/networks.py`, and in the same file, added to the function `FeedForwardDGL._parse_gnn_layer`.

To be used in the configuration file as a `goli.model.layer_name`, it must also be implemented with some variable parameters in the file `expts/config_gnns.yaml`.

### Adding a new NN architecture

All NN and GNN architectures compatible with the `DGL` library are provided in the file `goli/dgl/networks.py`. When implementing a new architecture, it is highly recommended to inherit from `goli.dgl.networks.FeedForwardNN` for regular neural networks, from `goli.dgl.networks.FeedForwardDGL` for DGL neural network, or from any of their sub-classes.

When adding any new parameter, it is always a good idea to register the parameters in the dictionary `self.hparams`. This dictionary is used by Pytorch-Lightning to track the hyper-parameters in Tensorboard.

### Changing the ModelWrapper and loss function

The `ModelWrapper` is a general pytorch-lightning module that should work with any kind of `pytorch.nn.Module` or `pl.LightningModule`. The class defines a structure of including models, loss functions, batch sizes, collate functions, metrics...

Some loss functions are already implemented in the ModelWrapper, including `mse, bce, mae, cosine`, but some tasks will require more complex loss functions. One can add any new function in `goli.trainer.model_wrapper.ModelWrapper._parse_loss_fun`.

### Changing the metrics used

**_!WARNING! The metrics implementation was done for pytorch-lightning v0.8. There has been major changes to how the metrics are used and defined, so the whole implementation must change._**

Our current code is compatible with the metrics defined by _pytorch-lightning_, which include a great set of metrics. We also added the PearsonR and SpearmanR as they are important correlation metrics. You can define any new metric in the file `goli/trainer/metrics.py`. The metric must inherit from `TensorMetric` and must be added to the dictionary `goli.trainer.metrics.METRICS_DICT`.

To use the metric, you can easily add it's name from `METRICS_DICT` in the yaml configuration file, at the address `metrics.metrics_dict`. Each metric has an underlying dictionnary with a mandatory `threshold` key containing information on how to threshold the prediction/target before computing the metric. Any `kwargs` arguments of the metric must also be added.

## Running a hyper-parameter search

In the current repository, we use `hydra-core` to launch multiple experiments in a grid-search manner. It works by specifying the parameters that we want to change from a given YAML file.

Below is an example of running a set of 3\*2\*2\*2=24 experiments, 3 variations of the gnn type _layer_name_, 2 variations of the learning rate _lr_, 2 variations of the hidden dimension _hidden_dim_, 2 variations of the network depth _hidden_depth_. All parameters not mentionned in the code below are unchanged from the file `expts/main_micro_ZINC.py`.

    python expts/main_micro_ZINC.py --multirun \
    model.layer_name=gin,gcn,pna-simple3 \
    constants.exp_name="testing_hydra" \
    constants.device="cuda:0" \
    constants.ignore_train_error=true \
    model_wrapper.lr=1e-4,1e-3 \
    model.gnn_kwargs.hidden_dim=32,64 \
    model.gnn_kwargs.hidden_depth=4,8

The results of the run will be available in the folder `multirun/[CURRENT-DATE]/[CURRENT-TIME]`. To open the results in tensorflow, run the following command using _bash_ or _powershell_

`tensorboard --logdir 'multirun/[CURRENT-DATE]/[CURRENT-TIME]/' --port 8000`

Then open a web-browser and enter the address `http://localhost:8000/`.