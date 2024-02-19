#! /usr/bin/env bash

if [ ! -f "/etc/apt/sources.list.d/jenkins.list" ]
then
    cucr-install-echo "Adding Jenkins sources to apt-get"
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
    cucr-install-apt-get-update
    cucr-install-debug "Added Jenkins sources to apt-get succesfully"
else
    cucr-install-debug "Jenkins sources already added to apt-get"
fi

cucr-install-system jenkins
