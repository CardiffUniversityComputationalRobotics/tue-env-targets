#!/bin/bash

# if [[ "$ROS_DISTRO" == "humble" ]]; then
if [ ! -d ~/libfranka/ ]; then
    # cd ~/ros/humble/repos/github.com/frankaemika/
    cd ~
    sudo apt remove "*libfranka*"
	sudo apt install build-essential cmake git libpoco-dev libeigen3-dev python3-rosdep2
    git clone --recursive https://github.com/frankaemika/libfranka.git --branch 0.13.3
    cd libfranka
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF  ..
    cmake --build . -j$(nproc)
    cpack -G DEB
    sudo dpkg -i libfranka-*.deb
    cd ~/ros/humble/system/
    rosdep update
	rosdep install --from-paths src --ignore-src --rosdistro humble -y --skip-keys libfranka
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
