#! /usr/bin/env bash

# NVlabs GraspGen (diffusion grasp generator) for inference: ~/dev/GraspGen at a fixed commit, the micromamba
# environment 'graspgen' with the pointnet2_ops CUDA extension, and the Franka Hand model in ~/dev/models/graspgen.

repo_dir="${HOME}/dev/GraspGen"
env_name="graspgen"
graspgen_commit="2dd8852e1be60f5f9d277fafcc621835cdf59110"
models_dir="${HOME}/dev/models/graspgen"
models_url="https://huggingface.co/adithyamurali/GraspGenModels/resolve/ec1ccbb5eec0680db669246ac312a3636f16ee43/checkpoints"

cucr-install-git https://github.com/NVlabs/GraspGen.git --target-dir="${repo_dir}" --version="${graspgen_commit}"

export MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX:-${HOME}/micromamba}
micromamba_bin=$(command -v micromamba || echo "${HOME}/.local/bin/micromamba")
run_in_env=("${micromamba_bin}" run -n "${env_name}")

"${CUCR_INSTALL_TARGETS_DIR}"/micromamba/create_env.bash "${env_name}" "${CUCR_INSTALL_CURRENT_TARGET_DIR}/environment.yml" || \
    cucr-install-error "Failed to create the micromamba environment '${env_name}'"

# GraspGen and its pip dependencies (pinned in its pyproject.toml); torch and the PyG packages come from the environment
if ! "${run_in_env[@]}" pip show grasp_gen &>/dev/null
then
    cucr-install-info "Installing GraspGen in '${env_name}'"
    "${run_in_env[@]}" pip install -e "${repo_dir}" || \
        cucr-install-error "Failed to install GraspGen in '${env_name}'"
fi

# pointnet2_ops CUDA extension, built with the compilers of the environment for the local GPU
if ! "${run_in_env[@]}" python -c "import pointnet2_ops._ext" &>/dev/null
then
    cucr-install-info "Building pointnet2_ops in '${env_name}'"
    env_prefix="${MAMBA_ROOT_PREFIX}/envs/${env_name}"
    gpu_arch=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader 2>/dev/null | head -n 1)
    CUDA_HOME="${env_prefix}" \
    CPATH="${env_prefix}/targets/x86_64-linux/include" \
    CC="${env_prefix}/bin/x86_64-conda-linux-gnu-gcc" \
    CXX="${env_prefix}/bin/x86_64-conda-linux-gnu-g++" \
    CUDAHOSTCXX="${env_prefix}/bin/x86_64-conda-linux-gnu-g++" \
    TORCH_CUDA_ARCH_LIST="${gpu_arch:-8.9}" \
        "${run_in_env[@]}" pip install --no-build-isolation "${repo_dir}/pointnet2_ops" || \
        cucr-install-error "Failed to build pointnet2_ops in '${env_name}'"
fi

# Franka Hand model (generator + discriminator)
mkdir -p "${models_dir}"
while read -r file sha256
do
    if [[ ! -f "${models_dir}/${file}" ]] || { [[ -n "${sha256}" ]] && [[ "$(sha256sum "${models_dir}/${file}" | cut -d ' ' -f 1)" != "${sha256}" ]]; }
    then
        cucr-install-info "Downloading the GraspGen model ${file}"
        curl -fL "${models_url}/${file}" -o "${models_dir}/${file}.part" || cucr-install-error "Failed to download ${file}"
        if [[ -n "${sha256}" ]] && [[ "$(sha256sum "${models_dir}/${file}.part" | cut -d ' ' -f 1)" != "${sha256}" ]]
        then
            rm -f "${models_dir}/${file}.part"
            cucr-install-error "Checksum of ${file} does not match"
        fi
        mv "${models_dir}/${file}.part" "${models_dir}/${file}"
    fi
done <<MODELS
graspgen_franka_panda.yml
graspgen_franka_panda_gen.pth 0597583b89b322d42ceb4e596967d6ed68d1b56cba4039895909ccd5bdc66eff
graspgen_franka_panda_dis.pth e47d703c63b54c2d11fbc1effd43898f251b4147250888541e3b16e9c0d19e1c
MODELS
