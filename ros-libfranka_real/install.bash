#!/bin/bash

# Real-robot path: libfranka 0.13.2 (FCI server v6 limit). 0.13.x has no
# package.xml so it cannot be built by colcon. This script does the
# manual cmake+cpack+dpkg flow that produces a system .deb, then asks
# rosdep to skip the libfranka key when resolving fsa2's deps.

if [[ "$ROS_DISTRO" == "humble" ]]; then
    sudo apt install -y build-essential cmake git libpoco-dev libeigen3-dev python3-rosdep2 libfmt-dev lsb-release curl

    if ! grep -q '^deb .*robotpkg' /etc/apt/sources.list.d/robotpkg.list 2>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL http://robotpkg.openrobots.org/packages/debian/robotpkg.asc | sudo tee /etc/apt/keyrings/robotpkg.asc
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/robotpkg.asc] http://robotpkg.openrobots.org/packages/debian/pub $(lsb_release -cs) robotpkg" | sudo tee /etc/apt/sources.list.d/robotpkg.list
        sudo apt-get update
    fi
    sudo apt-get install -y robotpkg-pinocchio

    LIBFRANKA_DIR=~/ros/humble/repos/github.com/frankaemika/libfranka
    if [ ! -d "$LIBFRANKA_DIR" ]; then
        mkdir -p "$(dirname "$LIBFRANKA_DIR")"
        git clone --recursive https://github.com/frankaemika/libfranka.git --branch 0.13.2 "$LIBFRANKA_DIR"
    else
        cd "$LIBFRANKA_DIR"
        git fetch
        git checkout 0.13.2
        git submodule update --init --recursive
    fi

    cd "$LIBFRANKA_DIR"
    rm -rf build
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF ..
    cmake --build . -j"$(nproc)"
    cpack -G DEB
    sudo dpkg -i libfranka-*.deb

    cd ~/ros/humble/system/
    rosdep update
    rosdep install --from-paths src --ignore-src --rosdistro humble -y --skip-keys libfranka
fi