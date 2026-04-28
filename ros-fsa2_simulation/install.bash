# add 'out' and 'cabinet_with_apriltag' to ~/.gazebo/models

mkdir -p ~/.gazebo/models
# cp ~/ros/humble/repos/github.com/CardiffUniversityComputationalRobotics/fsa2/fsa2_simulation/worlds/models/* ~/.gazebo/models/ -r
cp ~/ros/humble/repos/github.com/ioannismarios/fsa2_vc/fsa2_simulation/worlds/models/* ~/.gazebo/models/ -r


# setup needed for gazebo classic
if ! grep -q "export GZ_SIM_RESOURCE_PATH=" ~/.bashrc;
    then
        echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.gazebo/models/ >> ~/.bashrc
fi