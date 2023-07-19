if [ ! -d $CUCR_SYSTEM_DIR/src/moveit ]
then
    cucr-install-target ros-moveit
    cucr-install-target ros-moveit_msgs
    cucr-install-target ros-moveit_resources
    cucr-install-target ros-ompl
    cucr-install-target ros-ruckig
fi
