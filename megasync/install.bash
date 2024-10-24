#! /usr/bin/env bash

DATA_DIR="$HOME/MEGA"
if [ ! -d "$DATA_DIR" ]
then
    # Download mega sync
    UBUNTU_VERSION=$(lsb_release -r | sed 's/Release:\s*\(.*\)/\1/')
    cucr-install-debug "Ubuntu version: $UBUNTU_VERSION"

    LINK="https://mega.nz/linux/MEGAsync/xUbuntu_""$UBUNTU_VERSION""/amd64/megasync-xUbuntu_""$UBUNTU_VERSION""_amd64.deb"
    DEST="/tmp/""$UBUNTU_VERSION""_MEGA_SYNC.deb"

    cucr-install-debug "Downloading $LINK to $DEST"
    wget "$LINK" -O "$DEST"

    # Install
    cucr-install-debug "Installing debian package ..."
    cucr-install-dpkg "$DEST"

    cucr-install-info "NOW Please configure the mega client with the AMIGO credentials"
fi
