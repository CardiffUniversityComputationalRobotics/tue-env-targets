#! /usr/bin/env bash

targets="$IROHMS_ENV_TARGETS_DIR/*"
for target in $targets
do
    target="$(basename "$target")"
    if [[ $target != "cucr-all" ]]
    then
        cucr-install-target "$target"
    fi
done
