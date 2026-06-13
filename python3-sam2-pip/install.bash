#! /usr/bin/env bash
# Pre-fetch the SAM2.1 Hiera-Large weights into the HuggingFace cache (~/.cache/huggingface)
# so the first segment() is fast. Built on CPU just to download — no GPU needed at install.
if [[ -z "${CI}" ]]
then
    python3 -c "from sam2.sam2_image_predictor import SAM2ImagePredictor; SAM2ImagePredictor.from_pretrained('facebook/sam2.1-hiera-large', device='cpu')" || \
        echo "sam2 weight pre-fetch skipped (will download on first use)"
fi
