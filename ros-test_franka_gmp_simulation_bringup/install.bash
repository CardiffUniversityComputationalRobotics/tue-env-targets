#!/bin/bash
# shellcheck disable=SC1090

if [ ! -d ~/dev/ContactGraspNet/ ]
then
	cucr-install-debug "Installing ContactGraspNet"
	git clone git@github.com:CardiffUniversityComputationalRobotics/ContactGraspNet.git ~/dev/ContactGraspNet
fi

# if [ ! -d ~/dev/UoisSegmentation/ ]
# then
# 	cucr-install-debug "Installing UoisSegmentation"
# 	git clone git@github.com:CardiffUniversityComputationalRobotics/UoisSegmentation.git ~/dev/UoisSegmentation
# fi
