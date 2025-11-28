#!/bin/bash

if [[ "$ROS_DISTRO" == "humble" ]]; then
if [ ! -d ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics/ ]; then
    # cd ~/ros/humble/repos/github.com/frankaemika/
    cd ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics
    # cd ~
    sudo apt remove "*libfranka*"
    sudo apt install build-essential cmake git libpoco-dev libeigen3-dev python3-rosdep2 libfmt-dev
    sudo apt-get install -y lsb-release curl
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL http://robotpkg.openrobots.org/packages/debian/robotpkg.asc | sudo tee /etc/apt/keyrings/robotpkg.asc
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/robotpkg.asc] http://robotpkg.openrobots.org/packages/debian/pub $(lsb_release -cs) robotpkg" | sudo tee /etc/apt/sources.list.d/robotpkg.list
    sudo apt-get update
    sudo apt-get install -y robotpkg-pinocchio
    # git clone --recursive https://github.com/frankaemika/libfranka.git --branch 0.13.3 # uses cmake 3.4 which is not supported anymore by cmake (min version is now 3.5)

    # git clone --recursive https://github.com/frankaemika/libfranka.git --branch 0.13.3
    git clone --recursive https://github.com/CardiffUniversityComputationalRobotics/libfranka.git
    cd libfranka
    git checkout -f ioannis_dev
    git submodule update

    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF ..
    cmake --build . -j$(nproc)
    cpack -G DEB
    sudo dpkg -i libfranka-*.deb
    cd ~/ros/humble/system/
    rosdep update
    rosdep install --from-paths src --ignore-src --rosdistro humble -y --skip-keys libfranka
fi
fi

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
