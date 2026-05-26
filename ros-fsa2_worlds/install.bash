# Populate ~/.gazebo/models/ from the shared fsa2_worlds asset set.
# Both fsa2_fr3 and fsa2_gen3 consume these via model:// URIs that resolve
# through GZ_SIM_RESOURCE_PATH (~/.gazebo/models/).

mkdir -p ~/.gazebo/models
if compgen -G "${HOME}/ros/humble/repos/github.com/ioannismarios/fsa2_vc/fsa2_worlds/worlds/models/*" > /dev/null; then
    cp ~/ros/humble/repos/github.com/ioannismarios/fsa2_vc/fsa2_worlds/worlds/models/* ~/.gazebo/models/ -r
fi

# Setup needed for gazebo classic (shared with fsa2_fr3 / fsa2_gen3 — append once).
if ! grep -q "export GZ_SIM_RESOURCE_PATH=" ~/.bashrc;
    then
        echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.gazebo/models/ >> ~/.bashrc
fi
