#!/bin/bash

# libfranka 0.18.0+ ships its own package.xml (build_type cmake) and is built
# by colcon as a workspace package. The version 0.13.x flow used to build a
# system .deb manually because there was no package.xml; that path is no
# longer needed. install.bash now only ensures the apt build-deps are
# present (eigen, fmt, poco, pinocchio) — pinocchio comes from
# robotpkg.openrobots.org rather than apt's own archive.
#
# Old 0.13.x build flow preserved as comments below for the real-robot path
# (FCI server v6 caps libfranka at 0.13.x; the manual deb build is needed
# there because 0.13.x has no package.xml).

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

# --- Real-robot (libfranka 0.13.x, FCI server v6) build flow ---
# Re-enable when reverting to the libfranka <= 0.13.x pin. 0.13.x has no
# package.xml so colcon won't build it; we need the manual cmake+cpack+dpkg
# path to produce a system .deb.
#
# if [[ "$ROS_DISTRO" == "humble" ]]; then
# if [ ! -d ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics/ ]; then
#     cd ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics
#     git clone --recursive https://github.com/frankaemika/libfranka.git --branch 0.13.2
#     cd libfranka
#     git submodule update
#     mkdir build
#     cd build
#     cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF ..
#     cmake --build . -j$(nproc)
#     cpack -G DEB
#     sudo dpkg -i libfranka-*.deb
#     cd ~/ros/humble/system/
#     rosdep update
#     rosdep install --from-paths src --ignore-src --rosdistro humble -y --skip-keys libfranka
# fi
# fi

# if [ ! -d ~/libfranka/ ]
# then
# 	sudo apt remove "*libfranka*"
# 	sudo apt install build-essential cmake git libpoco-dev libeigen3-dev
# 	git clone --recursive https://github.com/frankaemika/libfranka --branch 0.10.0 # only for FR3
# 	cd libfranka
# 	mkdir build
# 	cd build
# 	cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF ..
# 	cmake --build .
# 	cpack -G DEB
# 	sudo dpkg -i libfranka*.deb
# 	cd
# 	cd ros/noetic/system/
# 	rosdep install --from-paths src --ignore-src --rosdistro noetic -y --skip-keys libfranka

# fi
