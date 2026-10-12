#!/bin/bash

if [[ "$CUCR_ROS_DISTRO" != "humble" ]]; then
    # Jazzy+: libfranka is built from source in the workspace (see install.yaml), so no
    # system deb. Upstream franka_ros2 also contains packages (mobile, spine, ZED kit) whose
    # dependencies are not on apt, hence -r to keep going past them.
    cd "$CUCR_SYSTEM_DIR"
    rosdep update --rosdistro "$CUCR_ROS_DISTRO"
    rosdep install --from-paths src --ignore-src --rosdistro "$CUCR_ROS_DISTRO" -y -r --skip-keys libfranka
elif [ ! -d ~/libfranka/ ]; then
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
    cd "$CUCR_SYSTEM_DIR"
    rosdep update --rosdistro "$CUCR_ROS_DISTRO"
	rosdep install --from-paths src --ignore-src --rosdistro "$CUCR_ROS_DISTRO" -y --skip-keys libfranka
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
