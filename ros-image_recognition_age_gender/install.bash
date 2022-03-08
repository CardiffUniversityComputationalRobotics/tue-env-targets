#! /usr/bin/env bash

url="https://github.com/Nebula4869/PyTorch-gender-age-estimation/raw/038331d26fc1fbf24d00365d0eb9d0e5e828dda6/models-2020-11-20-14-37/best-epoch47-0.9314.onnx"
dest=~/data/pytorch_models

if [ ! -f $dest/"$(basename "$url")" ]
then
    tue-install-debug "wget $url -P $dest"
    wget $url -P $dest
fi
