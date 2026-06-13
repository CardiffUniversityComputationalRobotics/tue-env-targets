#! /usr/bin/env bash
# Fetch the EfficientSAM checkpoints (not shipped by pip) and expose their root.
# vitt is committed directly; vits ships zipped and is unzipped here.
set -e

ESAM_ROOT="$HOME/.cache/efficient_sam"

if [ ! -d "$ESAM_ROOT/.git" ]; then
    git clone --depth 1 https://github.com/yformer/EfficientSAM.git "$ESAM_ROOT"
fi

if [ ! -f "$ESAM_ROOT/weights/efficient_sam_vits.pt" ] && \
   [ -f "$ESAM_ROOT/weights/efficient_sam_vits.pt.zip" ]; then
    ( cd "$ESAM_ROOT/weights" && unzip -o efficient_sam_vits.pt.zip )
fi

# EFFICIENT_SAM_ROOT is read by perception/segment.py to locate weights/ at load.
if ! grep -q "EFFICIENT_SAM_ROOT" "$HOME/.bashrc"; then
    echo "export EFFICIENT_SAM_ROOT=$ESAM_ROOT" >> "$HOME/.bashrc"
fi
