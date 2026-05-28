# Populate ~/.gazebo/models/ from the shared iris_worlds asset set.
# iris_fr3, iris_gen3 and iris_husky all consume these via model:// URIs that
# resolve through GZ_SIM_RESOURCE_PATH (~/.gazebo/models/).
# Distro-parameterised on $CUCR_ROS_DISTRO so it works on humble and jazzy.

mkdir -p ~/.gazebo/models

WORLDS_REPO="${HOME}/ros/${CUCR_ROS_DISTRO:-humble}/repos/github.com/ioannismarios/iris_worlds"
if compgen -G "${WORLDS_REPO}/worlds/models/*" > /dev/null; then
    cp -r "${WORLDS_REPO}"/worlds/models/* ~/.gazebo/models/
fi

# Setup needed for gazebo classic (append once).
if ! grep -q "export GZ_SIM_RESOURCE_PATH=" ~/.bashrc;
    then
        echo 'export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/'"${CUCR_ROS_DISTRO:-humble}"'/system/src/:~/.gazebo/models/' >> ~/.bashrc
fi
