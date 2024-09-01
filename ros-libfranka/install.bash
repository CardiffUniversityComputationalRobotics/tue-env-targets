#!/bin/bash

if [[ "$ROS_DISTRO" == "humble" ]]; then
    cd ~/ros/humble/repos/github.com/frankaemika/libfranka
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF  ..
    cmake --build . -j$(nproc)
    cpack -G DEB
    sudo dpkg -i libfranka-*.deb
fi