# add 'out' and 'cabinet_with_apriltag' to ~/.gazebo/models

# tue-install-info "Adding AprilTag models to /home/$USER/.gazebo/models/"
mkdir -p ~/.gazebo/models
cp ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics/fsa2-kinova/fsa2_kinova_simulation/worlds/models/* ~/.gazebo/models/ -r

echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.gazebo/models/ >> ~/.bashrc

# setup needed for gazebo classic
if ! grep -q "export GZ_SIM_RESOURCE_PATH=" ~/.bashrc;
    then
        echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.gazebo/models/ >> ~/.bashrc
fi