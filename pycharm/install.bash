#! /usr/bin/env bash

pycharm="pycharm-community"
if dpkg-query -W -f='${Status}' $pycharm 2>/dev/null | grep -q "ok installed"
then
    cucr-install-debug "Pycharm was installed  by apt, removing it now"
    cucr-install-warning "Pycharm is now installed via SNAP. To remove the old apt version: sudo apt-get remove $pycharm"
else
    cucr-install-debug "Pycharm was not installed by apt"
fi

# Shortcut
cucr-install-cp pycharm-community_pycharm-community.desktop ~/.local/share/applications/pycharm-community_pycharm-community.desktop
