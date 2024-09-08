#!/bin/bash

if [[ "$ROS_DISTRO" == "humble" ]]; then
    cd ~/ros/humble/repos/github.com/frankaemika/
    rm -rf libfranka
    git clone https://github.com/frankaemika/libfranka.git --recursive
    git checkout 0.13.2
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF  ..
    cmake --build . -j$(nproc)
    cpack -G DEB
    sudo dpkg -i libfranka-*.deb
fi