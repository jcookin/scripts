#!/usr/bin/env bash

## Bootstraps ait host machine ##

# Load pretty-printing config and shared functions
# shellcheck source=../config.sh
source ../config.sh


set -x

## Kernel check

# check if kernel version with known issues
if [ -f bad_kernels.txt ]; then 
    if grep -Fxq "$(uname -r)" bad_kernels.txt; then
        pprint_err "kernel version is '$(uname -r)' -- recommend upgrading due to prior issues with this kernel version"
        # shellcheck disable=SC2162
        read -p "exit and manually upgrade kernel? (y/n)" doexit
        if [ "$doexit" == "y" ]; then
            exit 1
        fi
    fi
fi

## Package installs

# Update existing first

sudo apt-get update && sudo apt-get upgrade -y

install_packages

#######

## Setup Git

git config --global user.name "jcookin"
git config --global user.email ""
git config --global core.editor vim

## Vim setup
## Vundle

pprint_info "Setting up Vim w/ Vundle..."
if git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim; then
    pprint_ok "Success"
else
    pprint_err "Error installing Vundle, see output"
fi

## VSCode
pprint_info "Installing vscode..."

# Add microsoft APT repo
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Install code
sudo apt install apt-transport-https
sudo apt update
if sudo apt install code; then
    pprint_ok "Success"
else
    pprint_err "Error! See above logs"
fi

# Install extensions
pprint_info "Installing vscode extensions"
if xargs -L 1 code --install-extension < vscode-extensions.txt; then
    pprint_ok "Success"
else
    pprint_err "Error!"
fi

## Install hadolint (docker file linter)
pprint_info "Installing hadolint..."

if wget -O /tmp/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64; then
    chmod +x /tmp/hadolint
    sudo mv /tmp/hadolint /usr/local/bin/
    pprint_ok "Success"
else
    pprint_err "Errror! See output logs"
fi

pprint_ok "DONE"

## Install Docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

if sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    pprint_ok "Success"
else
    pprint_err "Error!"
fi

## Install nix (nix-env, nix-shell, etc)
pprint_info "Installing Nix..."

# Install single-user nix; multi-user not needed
if sh <(curl -L https://nixos.org/nix/install) --no-daemon; then
    pprint_ok "Success!"
else
    pprint_err "Error! See output"
fi

pprint_info "NOTICE: Recommend reboot before continuing"
