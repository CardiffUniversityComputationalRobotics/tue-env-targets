# TEMP: should be remove not later then 2022-06-24

catkin_version=$(catkin --version | awk 'NR==1{print $2}')

if dpkg --compare-versions "${catkin_version}" lt 0.8.5
then
    tue-install-info "Upgrading catkin-tools to >= 0.8.5, as 0.8.3 and 0.8.4 are broken"
    tue-install-pipe sudo apt-get install --assume-yes python3-catkin-tools
else
    tue-install-debug "Not updating catkin-tools. Installed version: ${catkin_version}"
fi
