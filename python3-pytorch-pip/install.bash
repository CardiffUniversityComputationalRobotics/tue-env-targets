#! /usr/bin/env bash
# Modern torch for the iris perception stack (EfficientSAM / GraspGen).
# Pinned to the versions validated on the RTX 4070 dev laptops (CUDA 13 wheels).
# Bump here if a machine needs a different CUDA build.

if [[ -z "${CI}" ]]
then
    cucr-install-pip "torch==2.12.0 -i https://download.pytorch.org/whl/cu130"
    cucr-install-pip "torchvision==0.27.0 -i https://download.pytorch.org/whl/cu130"
else
    cucr-install-pip "torch==2.12.0 -i https://download.pytorch.org/whl/cpu"
    cucr-install-pip "torchvision==0.27.0 -i https://download.pytorch.org/whl/cpu"
fi
