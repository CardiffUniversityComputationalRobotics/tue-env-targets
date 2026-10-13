#! /usr/bin/env bash

# SAM2 segmentation of the goal-region pipeline (DiffusionProject/process.py): ~/dev/DiffusionProject, the
# micromamba environment 'segmentation-sam2' and the SAM2 checkpoint in ~/dev/models/sam2.

repo_dir="${HOME}/dev/DiffusionProject"
env_name="segmentation-sam2"
sam2_commit="2b90b9f5ceec907a1c18123530e92e794ad901a4"
checkpoint="${HOME}/dev/models/sam2/sam2.1_hiera_base_plus.pt"
checkpoint_url="https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_base_plus.pt"
checkpoint_sha256="a2345aede8715ab1d5d31b4a509fb160c5a4af1970f199d9054ccfb746c004c5"

cucr-install-git https://github.com/frkndmn/DiffusionProject.git --target-dir="${repo_dir}" --version=jazzy-goalregion

export MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX:-${HOME}/micromamba}
micromamba_bin=$(command -v micromamba || echo "${HOME}/.local/bin/micromamba")

"${CUCR_INSTALL_TARGETS_DIR}"/micromamba/create_env.bash "${env_name}" "${repo_dir}/environment.yml" || \
    cucr-install-error "Failed to create the micromamba environment '${env_name}'"

# SAM2 without build isolation and without its optional CUDA extension, so it uses the torch of the environment
if ! "${micromamba_bin}" run -n "${env_name}" pip freeze 2>/dev/null | grep -q "sam2.git@${sam2_commit}"
then
    cucr-install-info "Installing SAM2 (${sam2_commit:0:7}) in '${env_name}'"
    SAM2_BUILD_CUDA=0 "${micromamba_bin}" run -n "${env_name}" pip install --no-build-isolation --no-deps \
        "SAM-2 @ git+https://github.com/facebookresearch/sam2.git@${sam2_commit}" || \
        cucr-install-error "Failed to install SAM2 in '${env_name}'"
fi

if [[ ! -f "${checkpoint}" ]] || [[ "$(sha256sum "${checkpoint}" | cut -d ' ' -f 1)" != "${checkpoint_sha256}" ]]
then
    cucr-install-info "Downloading the SAM2 checkpoint to ${checkpoint}"
    mkdir -p "$(dirname "${checkpoint}")"
    curl -fL "${checkpoint_url}" -o "${checkpoint}.part" || cucr-install-error "Failed to download ${checkpoint_url}"
    if [[ "$(sha256sum "${checkpoint}.part" | cut -d ' ' -f 1)" != "${checkpoint_sha256}" ]]
    then
        rm -f "${checkpoint}.part"
        cucr-install-error "Checksum of the downloaded SAM2 checkpoint does not match"
    fi
    mv "${checkpoint}.part" "${checkpoint}"
fi
