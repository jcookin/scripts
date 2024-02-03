#!/usr/bin/env bash

# Load print configuration for prettier output
source ../config.sh

# Configuration
pkg_file="*.packages.txt"

## Bootstraps ait host machine ##

set -x

## Package installs

install_packages

#######

## Setup Git

git config --global user.name "jcookin"
git config --global user.email ""
git config --global core.editor vim

## Vim setup
## Vundle

pprint_info "Setting up Vim w/ Vundle..."
if git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim ; then
    pprint_ok "Success"
else
    pprint_err "Error installing Vundle, see output"
fi

## VSCode
pprint_info "Installing vscode..."

# Add microsoft APT repo
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
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
if cat vscode-extensions.txt | xargs -L 1 code --install-extension; then
    pprint_ok "Success"
else
    pprint_err "Error!"
fi

## install hadolint (docker file linter)
pprint_info "Installing hadolint..."

if wget -O /tmp/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64; then
    chmod +x /tmp/hadolint
    sudo mv /tmp/hadolint /usr/local/bin/
    pprint_ok "Success"
else
    pprint_err "Errror! See output logs"
fi

pprint_ok "DONE"

## Install Hadolint
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

if sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    pprint_ok "Success"
else
    pprint_err "Error!"
fi

exit 0
