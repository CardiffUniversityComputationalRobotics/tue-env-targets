#! /usr/bin/env bash

# micromamba: a single static binary that creates the conda environments of the Python/GPU tools (segmentation,
# grasp planners, WGR scoring/generator). Tools create their environment with micromamba/create_env.bash.

micromamba_version="2.8.1-1"
micromamba_bin="${HOME}/.local/bin/micromamba"

if [[ -x "${micromamba_bin}" ]] && [[ "$("${micromamba_bin}" --version 2>/dev/null)" == "${micromamba_version%-*}" ]]
then
    cucr-install-debug "micromamba ${micromamba_version} is already installed"
    return 0
fi

cucr-install-info "Installing micromamba ${micromamba_version} to ${micromamba_bin}"
url="https://github.com/mamba-org/micromamba-releases/releases/download/${micromamba_version}/micromamba-linux-64"
tmp_dir=$(mktemp -d)
curl -fsSL "${url}" -o "${tmp_dir}/micromamba" || cucr-install-error "Failed to download ${url}"
curl -fsSL "${url}.sha256" -o "${tmp_dir}/micromamba.sha256" || cucr-install-error "Failed to download ${url}.sha256"
if [[ "$(sha256sum "${tmp_dir}/micromamba" | cut -d ' ' -f 1)" != "$(cut -d ' ' -f 1 "${tmp_dir}/micromamba.sha256")" ]]
then
    rm -rf "${tmp_dir}"
    cucr-install-error "Checksum of the downloaded micromamba does not match"
fi

mkdir -p "$(dirname "${micromamba_bin}")"
install -m 755 "${tmp_dir}/micromamba" "${micromamba_bin}"
rm -rf "${tmp_dir}"
