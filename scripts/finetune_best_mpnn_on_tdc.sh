#!/bin/bash

graphium-train \
    model=mpnn architecture=largemix tasks=largemix training=largemix accelerator=gpu datamodule.args.num_workers=0 trainer.trainer.precision=32 datamodule.args.persistent_workers=false trainer.model_checkpoint.dirpath=model_checkpoints/admet/mpnn/ +finetuning=admet_large_mpnn constants.max_epochs=100 datamodule.args.batch_size_training=32 finetuning.added_depth=5 finetuning.epoch_unfreeze_all=0 finetuning.pretrained_model=large-mpnn-v2 finetuning.sub_module_from_pretrained=l1000_mcf7 predictor.optim_kwargs.lr=0.0007985174192159161 "${@}"