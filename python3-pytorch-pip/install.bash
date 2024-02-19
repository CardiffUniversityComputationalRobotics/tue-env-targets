#! /usr/bin/env bash

if [[ -z "${CI}" ]]
then
    cucr-install-pip "torch==1.10.2+cu113 -i https://download.pytorch.org/whl/cu113"
    cucr-install-pip "torchvision==0.11.3+cu113 -i https://download.pytorch.org/whl/cu113"
else
    cucr-install-pip "torch==1.10.2+cpu -i https://download.pytorch.org/whl/cpu"
    cucr-install-pip "torchvision==0.11.3+cpu -i https://download.pytorch.org/whl/cpu"
fi
