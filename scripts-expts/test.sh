#!/bin/bash

set -e

source /home/frederik_valencediscovery_com/.bashrc
# cd /home/frederik_valencediscovery_com/projects/graphium_opt
micromamba activate graphium_dev

python -c "import graphium"

echo "success"