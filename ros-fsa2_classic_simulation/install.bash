# add 'out' and 'cabinet_with_apriltag' to ~/.gazebo/models

tue-install-info "Adding AprilTag models to /home/$USER/.gazebo/models/"
mkdir -p ~/.gazebo/models
cp ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics/fsa2_classic/fsa2_classic_simulation/worlds/models/* ~/.gazebo/models/ -r

# setup needed for gazebo classic
if ! grep -q "/usr/share/gazebo/setup.sh" ~/.bashrc;
    then
        echo "
# setup needed for gazebo classic
export LIBGL_ALWAYS_SOFTWARE=1
source /usr/share/gazebo/setup.sh" >> ~/.bashrc
    fi

# echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.ignition/models/ >> ~/.bashrc
