# add 'out' and 'cabinet_with_apriltag' to ~/.gazebo/models

tue-install-info "Adding AprilTag models to /home/$USER/.gazebo/models/"
mkdir -p ~/.gazebo/models
cp ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics/fsa2_classic/fsa2_classic_simulation/worlds/models/* ~/.gazebo/models/ -r

# setup needed for gazebo classic
if ! grep -q "/usr/share/gazebo/setup.sh" ~/.bashrc;
    then
        echo "
# setup needed for gazebo classic
source /usr/share/gazebo/setup.sh
export LIBGL_ALWAYS_SOFTWARE=1
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:${ROS_PACKAGE_PATH}
export GAZEBO_RESOURCE_PATH=$GAZEBO_RESOURCE_PATH:${ROS_PACKAGE_PATH}" >> ~/.bashrc
    fi

# echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.ignition/models/ >> ~/.bashrc
