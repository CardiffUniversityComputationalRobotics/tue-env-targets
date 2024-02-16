#! /usr/bin/env bash

github_url="https://github.com/cucr-robotics/GPSRCmdGen.git"
dest="$HOME/src/GPSRCmdGen"

# by default, set the previous commit to -1, which will trigger a 'make'
prev="-1"

if [ -d "$dest" ]
then
    # shellcheck disable=SC2164
    cd "$dest"
    current_url=$(git config --get remote.origin.url) # get the remote
    current_url_corrected="$(_git_https_or_ssh "$current_url")"
    github_url_corrected="$(_git_https_or_ssh "$github_url")"

    # if the GSPRCmdGen is pointing to the wrong remote, correct it
    if [ "$current_url_corrected" != "$github_url_corrected" ]
    then
        cucr-install-debug "The GPSRCmdGen is still pointing to old remote, will be changed to cucr-fork"
        git remote set-url origin "$github_url_corrected"
    fi

    # Git is set-up correctly, so record the previous commit
    prev=$(git rev-list HEAD -n 1)
fi

# cucr-install-git will decide if clone or pull is needed
cucr-install-git $github_url --target-dir="$dest"

# make if needed
# shellcheck disable=SC2164
cd "$dest"
if [ "$prev" != "$(git rev-list HEAD -n 1)" ]; then
    cucr-install-debug "Making GPSRCmdGen"
    make
else
    cucr-install-debug "GPSRCmdGen not updated, so not needed to make again"
fi
