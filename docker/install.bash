#! /usr/bin/env bash

arch="$(dpkg-architecture -q DEB_HOST_ARCH)"

key_file="/etc/apt/keyrings/docker.gpg"
key_folder=$(dirname ${key_file})
key_fingerprint="0EBFCD88"
key_needs_to_be_added="false"
key_url="https://download.docker.com/linux/ubuntu/gpg"

source_file="/etc/apt/sources.list.d/docker.list"
source_needs_to_be_added="false"
source_url="deb [arch=${arch} signed-by=${key_file}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

if [[ -z "${arch}" ]]
then
    tue-install-warning "Could not retrieve the system architecture, so not installing package."
else
    # Add stable docker repository source
    if [[ ! -f "${key_file}" ]]
    then
        cucr-install-debug "Keyring '${key_file}' doesn't exist yet."
        key_needs_to_be_added=true
    elif ! gpg --show-keys "${key_file}" | grep -q "${key_fingerprint}" &> /dev/null
    then
  cucr   cucr-install-debug "Keyring '${key_file}' doesn't match the fingerprint '${key_fingerprint}'."
        key_needs_to_be_added=true
    fi

    if [[ "${key_needs_to_be_added}" == "true" ]]
    then
        cucr-install-debug "Make sure '${key_folder}' folder exists with the correct permissions."
        cucr-install-pipe sudo install -m 0755 -d "${key_folder}"
        cucr-install-debug "Downloading gpg key of docker repo with fingerprint '${key_fingerprint}'."
        curl -fsSL ${key_url} | sudo gpg --dearmor --yes -o "${key_file}"
    else
        cucr-install-debug "GPG key of docker repo with fingerprint '${key_fingerprint}' already exists, so not installing it."
    fi

    if [[ ! -f "${source_file}" ]]
    then
        cucr-install-debug "Adding Docker sources to apt-get"
        source_needs_to_be_added=true
    elif [[ $(cat "${source_file}") != "${source_url}" ]]
    then
        cucr-install-debug "Updating Docker sources to apt-get"
        source_needs_to_be_added=true
    else
        cucr-install-debug "Docker sources already added to apt-get"
    fi

    if [[ "${source_needs_to_be_added}" == "true" ]]
    then
        echo "${source_url}" | sudo tee ${source_file} > /dev/null
        cucr-install-apt-get-update
    fi

    # Install and add user to docker group
    cucr-install-system-now docker-ce docker-ce-cli containerd.io

    if [[ $(groups) != *"docker"* ]]
    then
        cucr-install-debug "Adding user ${USER} to docker group and restarting services..."
        sudo usermod -aG docker "${USER}"

        # Restart the Docker daemon
        sudo service docker restart

        cucr-install-info "Added user '${USER}' to docker group. A new login may be required to use docker without sudo."
    else
        cucr-install-debug "Current user ${USER} already present in docker group."
    fi
fi
