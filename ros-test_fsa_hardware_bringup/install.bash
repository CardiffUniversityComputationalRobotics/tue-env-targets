#!/bin/bash
# shellcheck disable=SC1090

if [ ! -d ~/libfranka/ ]
then
	cucr-install-debug "Installing CoppeliaSim"
	sudo apt remove "*libfranka*"
	sudo apt install build-essential cmake git libpoco-dev libeigen3-dev
	git clone --recursive https://github.com/frankaemika/libfranka --branch 0.10.0 # only for FR3
	cd libfranka
	mkdir build
	cd build
	cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF ..
	cmake --build .
	cpack -G DEB
	sudo dpkg -i libfranka*.deb
	cd
	cd ros/noetic/system/
	rosdep install --from-paths src --ignore-src --rosdistro noetic -y --skip-keys libfranka

fi
