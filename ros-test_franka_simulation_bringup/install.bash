#!/bin/bash
# shellcheck disable=SC1090

# this is for ROS1
if [ "$ROS_DISTRO" == "noetic" ]; then
	if [ ! -d ~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04/ ]; then
		cucr-install-debug "Installing CoppeliaSim"
		wget -P ~/ https://downloads.coppeliarobotics.com/V4_1_0/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz && tar -xJf ~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz -C ~/
		echo '# CoppeliaSim env viarables' >>~/.bashrc
		echo 'export COPPELIASIM_ROOT=~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04/' >>~/.bashrc
		echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COPPELIASIM_ROOT' >>~/.bashrc
		echo 'export QT_QPA_PLATFORM_PLUGIN_PATH=$COPPELIASIM_ROOT' >>~/.bashrc
		rm ~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz
		export COPPELIASIM_ROOT=~/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04/
		export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COPPELIASIM_ROOT
		export QT_QPA_PLATFORM_PLUGIN_PATH=$COPPELIASIM_ROOT
	fi

else

	# setup needed for gazebo ignition
	if ! grep -q "export GZ_SIM_RESOURCE_PATH" ~/.bashrc; then

		echo "
# setup needed for gazebo ignition
export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.ignition/models/" >>~/.bashrc
	fi

fi

if [ ! -d ~/PyRep/ ]
	pip3 install -r requirements.txt
	source ~/.bashrc
	pip3 install .
fi
