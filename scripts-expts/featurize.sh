#!/usr/bin/env bash

## Name of your SLURM job
#SBATCH --job-name=feat

## Files for logs: here we redirect stoout and sterr to the same file
#SBATCH --output=outputs/feat.out
#SBATCH --error=outputs/error_feat.out
#SBATCH --open-mode=append

## Time limit for the job
#SBATCH --time=120:00:00

## Partition to use,
#SBATCH --partition=c112

set -e

micromamba run -n graphium_dev -c graphium data prepare \
    architecture=largemix \
    tasks=largemix \
    training=largemix \