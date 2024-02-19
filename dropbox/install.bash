#! /usr/bin/env bash

if [ ! -f /etc/apt/sources.list.d/dropbox.list ]
then
    cucr-install-echo "Adding Dropbox sources to apt-get"
    sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
    sudo sh -c 'echo "deb http://linux.dropbox.com/ubuntu/ trusty main" >> /etc/apt/sources.list.d/dropbox.list'
    cucr-install-apt-get-update
    cucr-install-debug "Added Dropbox sources to apt-get succesfully"
else
    cucr-install-debug "Dropbox sources already added to apt-get"
fi

cucr-install-system dropbox
