# Gen3 worlds models (currently empty — populated at Phase 5.4 when sim worlds land).

mkdir -p ~/.gazebo/models
if compgen -G "${HOME}/ros/humble/repos/github.com/ioannismarios/fsa2_vc/fsa2_gen3/worlds/models/*" > /dev/null; then
    cp ~/ros/humble/repos/github.com/ioannismarios/fsa2_vc/fsa2_gen3/worlds/models/* ~/.gazebo/models/ -r
fi


# setup needed for gazebo classic (shared with fsa2_fr3 — append once)
if ! grep -q "export GZ_SIM_RESOURCE_PATH=" ~/.bashrc;
    then
        echo export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:~/ros/humble/system/src/:~/.gazebo/models/ >> ~/.bashrc
fi