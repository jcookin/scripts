#!/usr/bin/env bash
# shellcheck disable=SC2059

# Colors

NC="\033[0m"
GREEN="\033[38;5;35m"
RED="\033[38;5;196m"
BLUE="\033[38;5;99m"


pprint_ok() {
    printf "${GREEN} > $1 ${NC}\n"
}

pprint_err() {
    printf "${RED} > $1 ${NC}\n"
}

pprint_info() {
    printf "${BLUE} > $1 ${NC}\n"
}
