#! /usr/bin/env bash

if [[ ! -f /etc/apt/sources.list.d/google-chrome.list ]]
then
    cucr-install-echo "Adding Chrome sources to apt-get"
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/chrome.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    cucr-install-apt-get-update
    cucr-install-debug "Added Chrome sources to apt-get succesfully"
else
    cucr-install-debug "Chrome sources already added to apt-get"
fi
