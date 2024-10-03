#!/usr/bin/env bash

## Bootstraps ait host machine ##

# Load pretty-printing config and shared functions
# shellcheck source=../config.sh
source ../config.sh
# shellcheck source=../install_scripts.sh
source ../install_scripts.sh

ossdir="$HOME/repos/oss"

set -x

## Kernel check

# check if kernel version with known issues
## https://community.frame.work/t/guide-linux-mint-on-laptop-13-with-amd-7040/37889
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

## PPA/APT Package installs

install_packages

######

## Setup Git

git config --global user.name "jcookin"
git config --global user.email ""
git config --global core.editor vim

## Configure folder structures for installs

mkdir -p "$ossdir"

## Vim setup
install_vundle

install_vscode

# install_vscode_extensions

install_hadolint

install_docker

install_nix

install_spotify

install_steam

install_minecraft

install_wine

install_android_studio

install_proton_vpn

install_alt_btop_1_3_2 "$ossdir"   # pass the directory to clone oss repos for building
install_rocm_smi "$ossdir"

install_talosctl
install_kubectl


pprint_info ">>> NOTICE: Recommend reboot <<<"
pprint_ok "DONE"