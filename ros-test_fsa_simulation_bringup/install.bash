#!/bin/bash
# shellcheck disable=SC1090

if [ ! -d ~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04/ ]
then
	cucr-install-debug "Installing CoppeliaSim"
	wget -P ~/ https://www.coppeliarobotics.com/files/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz &&  tar -xJf ~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz -C ~/
	echo '# CoppeliaSim env viarables' >> ~/.bashrc
	echo 'export COPPELIASIM_ROOT=~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04/' >> ~/.bashrc
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COPPELIASIM_ROOT' >> ~/.bashrc
	echo 'export QT_QPA_PLATFORM_PLUGIN_PATH=$COPPELIASIM_ROOT' >> ~/.bashrc
	rm ~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz
	export COPPELIASIM_ROOT=~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04/
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COPPELIASIM_ROOT
	export QT_QPA_PLATFORM_PLUGIN_PATH=$COPPELIASIM_ROOT
fi


if [ ! -d ~/PyRep/ ]
then
	cucr-install-debug "Installing PyRep"
	git clone git@github.com:stepjam/PyRep.git ~/PyRep
	cd ~/PyRep/
	pip3 install -r requirements.txt
	source ~/.bashrc
	pip3 install .
fi

# add 'out' and 'cabinet_with_apriltag' to ~/.gazebo/models

tue-install-info "Adding AprilTag models to /home/$USER/.gazebo/models/"
mkdir -p ~/.gazebo/models
cp ~/ros/noetic/repos/github.com/CardiffUniversityComputationalRobotics/shared_autonomy_manipulator/test_fsa_simulation_bringup/worlds/models/* ~/.gazebo/models/ -r
