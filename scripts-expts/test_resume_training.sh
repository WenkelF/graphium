#!/bin/bash

set -e

source /home/frederik_valencediscovery_com/.bashrc

micromamba activate graphium_dev

# graphium-train \
#     model=gin \
#     trainer.model_checkpoint.dirpath=models_checkpoints/dummy/${now:%Y-%m-%d_%H-%M-%S}/ \
#     trainer.trainer.check_val_every_n_epoch=1 \
#     constants.wandb.project=test-resume-training \
#     constants.max_epochs=4 \

graphium-train \
    model=gin \
    trainer.model_checkpoint.dirpath=model_checkpoints/dummy-resumed/${now:%Y-%m-%d_%H-%M-%S}/ \
    trainer.trainer.check_val_every_n_epoch=1 \
    constants.wandb.project=test-resume-training \
    constants.max_epochs=4 \
    +trainer.resume_from_checkpoint=model_checkpoints/dummy/last.ckpt \
    trainer.model_checkpoint.save_last=false \