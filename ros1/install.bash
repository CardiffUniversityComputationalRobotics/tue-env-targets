#! /usr/bin/env bash
# shellcheck disable=SC1090

if [ -z "$CUCR_ROS_DISTRO" ]
then
    cucr-install-error "CUCR_ROS_DISTRO was not set"
    return 1
fi

# Install basic ROS packages.
cucr-install-system-now ros-"$CUCR_ROS_DISTRO"-ros

if [ ! -d /etc/ros/rosdep ]
then
    sudo rosdep init || true # make sure it always succeeds, even if rosdep init was already called
fi

rosdep_update_file="/tmp/cucr_rosdep_update_${USER}"
if [ ! -f "$rosdep_update_file" ]
then
    cucr-install-debug "Updating rosdep"
    cucr-install-pipe rosdep update --rosdistro "$CUCR_ROS_DISTRO"
    touch "$rosdep_update_file"
fi

mkdir -p "$CUCR_SYSTEM_DIR"

if [ ! -f "$CUCR_SYSTEM_DIR"/devel/setup.bash ]
then
    [[ -z "${CUCR_ROS_VERSION}" ]] && { cucr-install-warning "cucr-env variable CUCR_ROS_VERSION is not set. This will not be allowed in the future.\nSetting CUCR_ROS_VERSION=1 temporarily."; }
    [[ "$CI" == "true" ]] && status_args=" --no-status"
    # shellcheck disable=SC2086
    CUCR_ROS_VERSION=1 cucr-make${status_args} || cucr-install-error "Error in building the system workspace"
fi
