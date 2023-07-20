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
    cucr-install-target ros-srdfdom
    cucr-install-target ros-pybind11_catkin
    cucr-install-target ros-warehouse_ros
    cucr-install-target libglew-dev
    cucr-install-target ros-nodelet
    cucr-install-target ros-eigenpy
    cucr-install-target ros-cv_bridge

fi