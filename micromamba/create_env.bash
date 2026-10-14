#! /usr/bin/env bash

# Create (or update) a micromamba environment from an environment/lock file, for use in the install.bash of a tool:
#
#   "${CUCR_INSTALL_TARGETS_DIR}"/micromamba/create_env.bash <env name> <environment.yml | conda-lock.yml | explicit .lock>
#
# The environment is rebuilt only when the file changes (its sha256 is stored in the environment).

set -euo pipefail

if [[ $# -ne 2 ]]
then
    echo "Usage: $(basename "$0") <env name> <environment file>" >&2
    exit 1
fi

env_name=$1
env_file=$(readlink -f "$2")
micromamba_bin=$(command -v micromamba || echo "${HOME}/.local/bin/micromamba")
export MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX:-${HOME}/micromamba}

if [[ ! -f "${env_file}" ]]
then
    echo "[micromamba] Environment file '${env_file}' does not exist" >&2
    exit 1
fi

env_dir="${MAMBA_ROOT_PREFIX}/envs/${env_name}"
stamp="${env_dir}/.cucr-env-file.sha256"
checksum=$(sha256sum "${env_file}" | cut -d ' ' -f 1)

# The sourced ROS workspace puts its Python packages (another Python version) on PYTHONPATH; keep them out of the
# environment. Restored when the environment is deactivated.
isolate_python()
{
    mkdir -p "${env_dir}/etc/conda/activate.d" "${env_dir}/etc/conda/deactivate.d"
    cat > "${env_dir}/etc/conda/activate.d/cucr-isolate-python.sh" <<'EOF'
if [ -n "${PYTHONPATH+x}" ]; then export CUCR_SAVED_PYTHONPATH="${PYTHONPATH}"; fi
unset PYTHONPATH
EOF
    cat > "${env_dir}/etc/conda/deactivate.d/cucr-isolate-python.sh" <<'EOF'
if [ -n "${CUCR_SAVED_PYTHONPATH+x}" ]; then export PYTHONPATH="${CUCR_SAVED_PYTHONPATH}"; unset CUCR_SAVED_PYTHONPATH; fi
EOF
}

if [[ -f "${stamp}" ]] && [[ "$(cat "${stamp}")" == "${checksum}" ]]
then
    isolate_python
    echo "[micromamba] Environment '${env_name}' is up to date"
    exit 0
fi

echo "[micromamba] Creating environment '${env_name}' from ${env_file}"
# Without PYTHONPATH, so pip in the new environment does not see the packages of the ROS workspace
env -u PYTHONPATH "${micromamba_bin}" create --yes --name "${env_name}" --file "${env_file}"
isolate_python
echo "${checksum}" > "${stamp}"
