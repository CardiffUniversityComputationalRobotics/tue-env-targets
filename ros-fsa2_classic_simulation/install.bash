# add 'out' and 'cabinet_with_apriltag' to ~/.gazebo/models

tue-install-info "Adding AprilTag models to /home/$USER/.gazebo/models/"
mkdir -p ~/.ignition/models
cp ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics/fsa2_classic/fsa2_classic_simulation/worlds/models/* ~/.gazebo/models/ -r

# echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.ignition/models/ >> ~/.bashrc
