#! /usr/bin/env bash

# libtorch (C++ PyTorch) 2.5.1 with CUDA 12.4, cxx11 ABI (as ROS / MoveIt), in ~/dev/libtorch, for packages that run
# TorchScript models in C++ (goal_region_planners: diffusion / transformer goal sampling), and a micromamba environment
# 'cuda-12-4' with the CUDA toolkit pieces its CMake config needs. See ./setup for the CMake variables.

libtorch_version="2.5.1+cu124"
libtorch_dir="${HOME}/dev/libtorch"
libtorch_url="https://download.pytorch.org/libtorch/cu124/libtorch-cxx11-abi-shared-with-deps-${libtorch_version/+/%2B}.zip"

if [[ "$(cat "${libtorch_dir}/build-version" 2>/dev/null)" != "${libtorch_version}" ]]
then
    cucr-install-info "Downloading libtorch ${libtorch_version} (2.5 GB) to ${libtorch_dir}"
    tmp_dir=$(mktemp -d)
    # -4: download.pytorch.org hangs over IPv6 on some networks
    curl -4 -fL "${libtorch_url}" -o "${tmp_dir}/libtorch.zip" || cucr-install-error "Failed to download ${libtorch_url}"
    unzip -q "${tmp_dir}/libtorch.zip" -d "${tmp_dir}" || cucr-install-error "Failed to unpack libtorch"
    rm -rf "${libtorch_dir}"
    mkdir -p "$(dirname "${libtorch_dir}")"
    mv "${tmp_dir}/libtorch" "${libtorch_dir}"
    rm -rf "${tmp_dir}"
else
    cucr-install-debug "libtorch ${libtorch_version} is already installed"
fi

"${CUCR_INSTALL_TARGETS_DIR}"/micromamba/create_env.bash cuda-12-4 "${CUCR_INSTALL_CURRENT_TARGET_DIR}/cuda_environment.yml" || \
    cucr-install-error "Failed to create the micromamba environment 'cuda-12-4'"
