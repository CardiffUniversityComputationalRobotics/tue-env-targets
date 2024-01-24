#!/bin/bash
# shellcheck disable=SC1090

if [ ! -d ~/gazebo_models/ ]
then
	cucr-install-debug "Downloading gazebo models"
	sudo apt-get install unzip
	pip install gdown
	gdown 1YxY81B5so6pLZ0QJK7R7bfAHoaHpPLGD -O ~/  &&  unzip ~/gazebo_models.zip -d ~/
	rm ~/gazebo_models.zip
fi