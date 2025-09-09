DIR="/home/${USER}/ros/${ROS_DISTRO}/system/src/dr_spaam"
if [ -d "$DIR" ]; then
    :
else
    git clone https://github.com/CardiffUniversityComputationalRobotics/2D_lidar_person_detection.git /home/${USER}/ros/${ROS_DISTRO}/system/src/2D_lidar_person_detection
    mv /home/${USER}/ros/${ROS_DISTRO}/system/src/2D_lidar_person_detection/dr_spaam /home/${USER}/ros/${ROS_DISTRO}/system/src
    rm -rf /home/${USER}/ros/${ROS_DISTRO}/system/src/2D_lidar_person_detection
    cd /home/${USER}/ros/${ROS_DISTRO}/system/src/dr_spaam
    sudo python setup.py install
fi
