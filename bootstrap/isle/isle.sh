#!/usr/bin/env bash

## Bootstraps ait host machine ##

# Load pretty-printing config and shared functions
# shellcheck source=../config.sh
source ../config.sh
MEDIA_DIR_ROOT="$HOME"  # May also be a disk /mnt location

set -x

## Package installs ##

# Update existing first

sudo apt-get update && sudo apt-get upgrade -y

install_packages

#######

## Setup Git

git config --global user.name "jcookin"
git config --global user.email ""
git config --global core.editor vim

## Install Docker
pprint_info "Installing Docker..."

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

if sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    # Add user to docker group for non-root user use
    sudo groupadd docker
    sudo usermod -aG docker "$USER"
    pprint_ok "Success"
else
    pprint_err "Error!"
fi

## setup ProtonVPN
protonvpn_file=protonvpn-stable-release_1.0.3-3_all.deb

if {
	wget "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/$protonvpn_file"
	sudo dpkg -i ./$protonvpn_file && sudo apt update
	sudo apt install -y proton-vpn-gnome-desktop
	sudo apt update && sudo apt upgrade -y
   }; then

    pprint_ok "Success"
    rm "$protonvpn_file"
else
    pprint_err "Issue installing protonvpn"
fi



## Setup filesystem config
mkdir /"$MEDIA_DIR_ROOT"/media
mkdir /"$MEDIA_DIR_ROOT"/quarantine

## Disk mount for shared media
mkdir /mnt/media


pprint_info ">>> NOTICE: Recommend reboot <<<"
