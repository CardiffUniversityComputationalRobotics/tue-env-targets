#! /usr/bin/env bash

# Adaptive goal regions from the grasp poses of a grasp planner (AdaptiveGoalRegion/src/transform_and_cluster.py):
# ~/dev/AdaptiveGoalRegion and the micromamba environment 'adaptive-goal-region'.

repo_dir="${HOME}/dev/AdaptiveGoalRegion"
env_name="adaptive-goal-region"

cucr-install-git git@github.com:CardiffUniversityComputationalRobotics/AdaptiveGoalRegion.git --target-dir="${repo_dir}" --version=jazzy-goalregion

export MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX:-${HOME}/micromamba}
micromamba_bin=$(command -v micromamba || echo "${HOME}/.local/bin/micromamba")

"${CUCR_INSTALL_TARGETS_DIR}"/micromamba/create_env.bash "${env_name}" "${repo_dir}/environment.yml" || \
    cucr-install-error "Failed to create the micromamba environment '${env_name}'"

# The package itself, editable, so changes in the repository are used without reinstalling
if ! "${micromamba_bin}" run -n "${env_name}" pip show adaptive_goal_region &>/dev/null
then
    cucr-install-info "Installing adaptive_goal_region (editable) in '${env_name}'"
    "${micromamba_bin}" run -n "${env_name}" pip install --no-deps -e "${repo_dir}" || \
        cucr-install-error "Failed to install adaptive_goal_region in '${env_name}'"
fi
