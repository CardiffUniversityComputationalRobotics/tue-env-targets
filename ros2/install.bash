#! /usr/bin/env bash
# shellcheck disable=SC1090

if [ -z "$CUCR_ROS_DISTRO" ]
then
    cucr-install-error "CUCR_ROS_DISTRO was not set"
    return 1
fi

# Install basic ROS packages and eProsima DDS implementation.
cucr-install-system-now ros-"$CUCR_ROS_DISTRO"-ros-core ros-"$CUCR_ROS_DISTRO"-rmw-fastrtps-cpp

# Setup the build environment
mkdir -p "$CUCR_SYSTEM_DIR"

if [ ! -f "$CUCR_SYSTEM_DIR"/install/setup.bash ]
then
    [[ -z "${CUCR_ROS_VERSION}" ]] && { cucr-install-warning "cucr-env variable CUCR_ROS_VERSION is not set. This will not be allowed in the future.\nSetting CUCR_ROS_VERSION=2 temporarily."; }
    CUCR_ROS_VERSION=2 cucr-make || cucr-install-error "Error in building the ROS2 system workspace"
fi
