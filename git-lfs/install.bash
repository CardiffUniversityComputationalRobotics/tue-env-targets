#! /usr/bin/env bash

if ! git config --glob --get-regex "filter.lfs.*" &>/dev/null
then
    tue-install-pipe git lfs install
else
    tue-install-debug "git-lfs is already installed"
fi
