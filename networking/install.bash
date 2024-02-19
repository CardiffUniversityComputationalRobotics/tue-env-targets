#! /usr/bin/env bash

# shellcheck disable=SC1091
. /etc/os-release
if [ "$UBUNTU_CODENAME" == "xenial" ]
then
    # Install config file (mdns4_minimal is normally missing in xenial and should be present)

    # Replace nsswitch config file
    cucr-install-cp nsswitch.conf /etc/nsswitch.conf
fi

# Prevent resolving to ipv6 addresses. We're not ready for that yet
if grep -q 'use-ipv6=yes' /etc/avahi/avahi-daemon.conf
then
    cucr-install-echo "Disabling ipv6 in /etc/avahi/avahi-daemon.conf"
    sudo sed -i 's/use-ipv6=yes/use-ipv6=no/g' /etc/avahi/avahi-daemon.conf
fi

if grep -q '#publish-aaaa-on-ipv4' /etc/avahi/avahi-daemon.conf
then
    # Also change this setting by suggestion of this bug report: https://bugzilla.redhat.com/show_bug.cgi?id=669627
    sudo sed -i 's/#publish-aaaa-on-ipv4=yes/publish-aaaa-on-ipv4=no/g' /etc/avahi/avahi-daemon.conf
fi

## SSH
ssh_config=~/.ssh/config
ssh_controlmasters_dir=~/.ssh/controlmasters
ssh_key=~/.ssh/id_rsa

# Generate ssh key
generate_ssh="false"
# Generate ssh key when file does not exist yet
if [ ! -f "$ssh_key" ]
then
    cucr-install-debug "No ssh key exists yet"
    generate_ssh="true"
else
    # Generate new ssh key if length < 4096
    if [ "$(ssh-keygen -l -f "$ssh_key" | awk '{print $1}')" -lt 4096 ]
    then
        cucr-install-info "Generating new ssh key as length < 4096, you might need to copy the new key to the robots, GitHub, etc."
        generate_ssh="true"
    else
        cucr-install-debug "ssh key available with length >= 4096"
    fi
fi

if [ $generate_ssh == "true" ]
then
    cucr-install-debug "Generating ssh key"
    yes | ssh-keygen -t rsa -b 4096 -N "" -f "$ssh_key"
    rm -r ${ssh_controlmasters_dir:?}/* 2>/dev/null # close all connections, to prevent any possible weird behaviour
    ssh-add # Start using the new key
fi

# Enable persistent connection multiplexing
if [ ! -f $ssh_config ]
then
    touch $ssh_config
fi
if [ ! -d $ssh_controlmasters_dir ]
then
    mkdir -p $ssh_controlmasters_dir
fi
cucr-install-add-text ssh_persistent_connection_lines $ssh_config
