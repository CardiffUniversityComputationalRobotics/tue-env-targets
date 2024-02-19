#! /usr/bin/env bash

if [ ! -d "${HOME}"/src/openface ]
then
    cucr-install-git https://github.com/cmusatyalab/openface.git --target-dir=~/src/openface

    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    # shellcheck disable=SC1091
    source "$DIR"/torch.bash

    # shellcheck disable=SC2164
    cd "${HOME}"/src/openface
    python3 setup.py install --user

    models/get-models.sh
fi

if [[ $(python3 -c "import dlib") -ne 0 ]]
then
    cucr-install-error "DLIB is not properly installed"
fi

if [[ $(python3 -c "import cv2") -ne 0 ]]
then
    cucr-install-error "opencv2 is not properly installed"
fi

if [[ $(python3 -c "import openface") -ne 0 ]]
then
    cucr-install-error "openface is not properly installed"
fi
