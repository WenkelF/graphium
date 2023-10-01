#!/usr/bin/env bash

## Array to launch 8 runs, 4 at a time
#SBATCH --array=1-42%14

## Name of your SLURM job
## SBATCH --job-name=finetune

## Files for logs: here we redirect stoout and sterr to the same file
#SBATCH --output=outputs/out_%x_%j_%a.out   # %x=job-name, %j=jobid, %a=array-id
#SBATCH --error=outputs/error_%x_%j_%a.out
#SBATCH --open-mode=append

## Time limit for the job
#SBATCH --time=12:00:00

## Partition to use,
#SBATCH --partition=v1001

set -e
    
source /home/frederik_valencediscovery_com/.bashrc

micromamba activate graphium_dev

wandb agent --count 1 recursion/finetuning/w7ql5rmu