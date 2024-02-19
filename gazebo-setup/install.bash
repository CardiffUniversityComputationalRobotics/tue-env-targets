#! /usr/bin/env bash

arch="$(dpkg-architecture -q DEB_HOST_ARCH)"

key_file="/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg"
key_folder=$(dirname ${key_file})
key_fingerprint="AF249743"
key_needs_to_be_added="false"
key_url="https://packages.osrfoundation.org/gazebo.gpg"

source_file="/etc/apt/sources.list.d/gazebo-stable.list"
source_needs_to_be_added="false"
source_url="deb [arch=${arch} signed-by=${key_file}] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main"

if [[ -z "${arch}" ]]
then
    cucr-install-warning "Could not retrieve the system architecture, so not installing package."
else
    # Add stable docker repository source
    if [[ ! -f "${key_file}" ]]
    then
        cucr-install-debug "Keyring '${key_file}' doesn't exist yet."
        key_needs_to_be_added=true
    elif ! gpg --show-keys "${key_file}" | grep -q "${key_fingerprint}" &> /dev/null
    then
        cucr-install-debug "Keyring '${key_file}' doesn't match the fingerprint '${key_fingerprint}'."
        key_needs_to_be_added=true
    fi

    if [[ "${key_needs_to_be_added}" == "true" ]]
    then
        cucr-install-debug "Make sure '${key_folder}' folder exists with the correct permissions."
        cucr-install-pipe sudo install -m 0755 -d "${key_folder}"
        cucr-install-debug "Downloading gpg key of Gazebo repo with fingerprint '${key_fingerprint}'."
        curl -fsSL ${key_url} | sudo gpg --dearmor --yes -o "${key_file}"
    else
        cucr-install-debug "GPG key of Gazebo repo with fingerprint '${key_fingerprint}' already exists, so not installing it."
    fi

    if [[ ! -f "${source_file}" ]]
    then
        cucr-install-debug "Adding Gazebo sources to apt-get"
        source_needs_to_be_added=true
    elif [[ $(cat "${source_file}") != "${source_url}" ]]
    then
        cucr-install-debug "Updating Gazebo sources to apt-get"
        source_needs_to_be_added=true
    else
        cucr-install-debug "Gazebo sources already added to apt-get"
    fi

    if [[ "${source_needs_to_be_added}" == "true" ]]
    then
        echo "${source_url}" | sudo tee ${source_file} > /dev/null
        cucr-install-apt-get-update
    fi
fi
