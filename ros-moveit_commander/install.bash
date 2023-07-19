if [ ! -d $CUCR_SYSTEM_DIR/src/moveit ]
then
    cucr-install-target ros-moveit
    cucr-install-target ros-moveit_msgs
    cucr-install-target ros-moveit_resources
    cucr-install-target ros-ompl
    cucr-install-target ros-ruckig
    cucr-install-target ros-tf2_eigen
    cucr-install-target ros-rosparam_shortcuts
    cucr-install-target ros-eigen_stl_containers
    cucr-install-target ros-geometric_shapes
fi
