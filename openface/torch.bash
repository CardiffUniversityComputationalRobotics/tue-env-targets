#! /usr/bin/env bash

# shellcheck disable=SC2164
pushd . > /dev/null

# GitHub has disabled the 'git:// 'protocol, https://github.blog/2021-09-01-improving-git-protocol-security-github/
# This is safe to do for other repos as those are also not working anymore
git config --global url.https://github.com/.insteadOf git://github.com/

cucr-install-echo "Installing Torch"
if [ -n "$CUCR_CUDA" ]
then
    cucr-install-debug "Installing torch with CUDA capabilities"
    export TORCH_NVCC_FLAGS="-D__CUDA_NO_HALF_OPERATORS__"
fi

cucr-install-git https://github.com/cucr-robotics/torch-distro.git --target-dir=~/src/torch
# shellcheck disable=SC2164
cd ~/src/torch
cucr-install-debug "Installing Torch dependencies"
cucr-install-pipe bash install-deps || cucr-install-error "Error during install of dependencies of torch, check output above"
cucr-install-debug "Installing Torch"
cucr-install-pipe ./install.sh -s || cucr-install-error "Error during install of torch, check output above"

cucr-install-debug "source ~/src/torch/install/bin/torch-activate"
# shellcheck disable=SC1090
source ~/src/torch/install/bin/torch-activate

cucr-install-debug "Installing Torch Modules"

cucr-install-pipe luarocks install dpnn
cucr-install-pipe luarocks install nn
cucr-install-pipe luarocks install optim
cucr-install-pipe luarocks install csvigo
if [ -n "$CUCR_CUDA" ]
then
    cucr-install-pipe luarocks install cutorch #(only with CUDA)
    cucr-install-pipe luarocks install cunn #(only with CUDA)
fi
cucr-install-pipe luarocks install fblualib #(only for training a DNN)
cucr-install-pipe luarocks install tds #(only for training a DNN)
cucr-install-pipe luarocks install torchx #(only for training a DNN)
cucr-install-pipe luarocks install optnet #(optional, only for training a DNN)

#From http://serverfault.com/questions/201709/how-to-set-ld-library-path-in-ubuntu
#To define this variable, simply use (on the shell prompt):
export LD_LIBRARY_PATH=/usr/lib/openblas-base/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

#To make it permanent, you can edit the ldconfig files. First, create a new file such as:
sudo touch /etc/ld.so.conf.d/libopenblas-base.conf

#Second, add the path in the created file
sudo sh -c 'echo "/usr/lib/openblas-base/" > /etc/ld.so.conf.d/libopenblas-base.conf'

#Finally, run ldconfig to update the cache.
sudo ldconfig

cucr-install-echo "torch.bash finished"

# shellcheck disable=SC2164
popd > /dev/null
