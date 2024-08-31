#!/usr/bin/env bash

## Bootstraps ait host machine ##

# Load pretty-printing config and shared functions
# shellcheck source=../config.sh
source ../config.sh
# shellcheck source=../install_scripts.sh
source ../install_scripts.sh

MEDIA_DIR_ROOT="$HOME"  # May also be a disk /mnt location

set -x

## Package installs ##

# Update existing first

install_packages

#######

## Setup Git

git config --global user.name "jcookin"
git config --global user.email ""
git config --global core.editor vim

install_docker

install_proton_vpn

## Setup filesystem config
mkdir /"$MEDIA_DIR_ROOT"/media

## Disk mount for shared media
mkdir /mnt/media

pprint_info ">>> NOTICE: Recommend reboot <<<"
