targets=`ls ~/.tue/installer/targets`
for target in $targets
do
    if [[ $target != "tue-all" ]]
    then
        tue-install-target $target
    fi
done
