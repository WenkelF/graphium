#!/bin/bash

# graphium-train +finetune=admet

# graphium-train \
#     --cfg /home/frederik_valencediscovery_com/projects/graphium_hps/pretrained_models/large/mpnn.yaml \
#     +finetune=admet_large_mpnn \

graphium-train \
    model=mpnn architecture=largemix tasks=largemix training=largemix accelerator=gpu \
    datamodule.args.dataloading_from=ram \
    datamodule.args.num_workers=0 \
    datamodule.args.persistent_workers=False \
    trainer.trainer.precision=32 \
    trainer.model_checkpoint.dirpath=model_checkpoints/admet/mpnn/ \
    architecture.task_heads.pcba_1328.last_activation=sigmoid \
    datamodule.args.batch_size_training=32 \
    predictor.optim_kwargs.lr=0.0001 \
    datamodule.args.batch_size_inference=500 \
    +finetuning=admet_large_mpnn_bbb \