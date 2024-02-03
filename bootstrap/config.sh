#!/usr/bin/env bash
# shellcheck disable=SC2059

# Colors

NC="\033[0m"
GREEN="\033[38;5;35m"
RED="\033[38;5;196m"
BLUE="\033[38;5;99m"


pprint_ok() {
    set +x
    printf "${GREEN} > $1 ${NC}\n"
    set -x
}

pprint_err() {
    set +x
    printf "${RED} > $1 ${NC}\n"
    set -x
}

pprint_info() {
    set +x
    printf "${BLUE} > $1 ${NC}\n"
    set -x
}

install_packages() {
    set -x
    pkg_file="packages.txt"

    pprint_info "Installing apt packages..."

    sudo apt-get update

    if sudo apt-get install -y "$(grep -vE "^\s*#" $pkg_file | tr "\n" " ")"; then
        pprint_ok "Success"
    else
        pprint_err "Error! Unable to install packages"
    fi
}

