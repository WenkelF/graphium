#!/bin/bash

graphium-train \
  --config-path=/home/frederik_valencediscovery_com/projects/graphium_hps/expts/configs/ \
  --config-name=config_mpnn_10M.yaml \
  +finetuning=admet_base \
  constants.task=lipophilicity_astrazeneca \
  finetuning.finetuning_head.in_dim=653 \
  finetuning.finetuning_head.last_activation=none \
  wandb.entity=recursion \