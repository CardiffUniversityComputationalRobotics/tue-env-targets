#!/bin/bash

# Sim selector: same apt build-deps as the original ros-libfranka target
# (libfranka 0.18.0+ ships package.xml and is built by colcon).

if [[ "$ROS_DISTRO" == "humble" ]]; then
    sudo apt install -y build-essential cmake git libpoco-dev libeigen3-dev python3-rosdep2 libfmt-dev lsb-release curl

    if ! grep -q '^deb .*robotpkg' /etc/apt/sources.list.d/robotpkg.list 2>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL http://robotpkg.openrobots.org/packages/debian/robotpkg.asc | sudo tee /etc/apt/keyrings/robotpkg.asc
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/robotpkg.asc] http://robotpkg.openrobots.org/packages/debian/pub $(lsb_release -cs) robotpkg" | sudo tee /etc/apt/sources.list.d/robotpkg.list
        sudo apt-get update
    fi
    sudo apt-get install -y robotpkg-pinocchio
fi