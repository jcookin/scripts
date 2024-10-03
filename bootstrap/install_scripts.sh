#!/usr/bin/env bash

## Install processes unique to certain packages and applications
## Re-use these install scripts in each machines's profile as simple function calls to reduce repeated code

# shellcheck source=./config.sh
source ./config.sh

set -x

# Checks if the command is already installed, returns 1 if true, 0 if false
is_installed() {
    if command -v "$1" > /dev/null; then
        pprint_info "$1 already installed, skipping"
        return 0
    fi
    return 1
}

install_packages() {
    pkg_file="packages.txt"

    pprint_info "Installing apt packages..."

    # update existing first
    printf "Updating existing repository lists and packages before installing new..."
    sudo apt-get update && sudo apt-get upgrade -y

    # shellcheck disable=SC2046
    ## Do not quote the package list output from the pkg_file parse or apt interprets as one package
    if sudo apt-get install -y $(grep -vE "^\s*#" "$pkg_file" | tr "\n" " "); then
        pprint_ok "Success"
        return 0
    else
        pprint_err "Error! Unable to install some packages"
        return 1
    fi
}

install_vscode() {
    # Install code
    pprint_info "Installing VSCode..."

    if is_installed "code"; then
        return
    fi

    # Add microsoft APT repo
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    sudo apt install -y apt-transport-https
    sudo apt update
    if sudo apt install -y code; then
        pprint_ok "Success"
        return 0
    else
        pprint_err "Error installing 'vscode'"
        return 1
    fi
}

install_vscode_extensions() {
    # Install extensions
    pprint_info "Installing vscode extensions"
    if xargs -L 1 code --install-extension < vscode-extensions.txt; then
        pprint_ok "Success"
        return 0
    else
        pprint_err "Error installing 'VSCode Extensions'"
        return 1
    fi
}

install_vundle() {
    ## Vundle

    if ls ~/.vim/bundle/Vundle.vim ; then
      pprint_info "Vundle is already installed"
      return 0
    fi

    pprint_info "Setting up Vim w/ Vundle..."
    if git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim; then
        pprint_ok "Success"
        return 0
    else
        pprint_err "Error installing Vundle, see output"
        return 1
    fi
}

install_proton_vpn() {
    ## setup ProtonVPN
    protonvpn_file=protonvpn-stable-release_1.0.4_all.deb

    if is_installed "protonvpn-cli" || is_installed "protonvpn-app"; then
        return
    fi

    pprint_info "Installing protonvpn"
    if {
        wget "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/$protonvpn_file"
        sudo dpkg -i ./$protonvpn_file && sudo apt update
        sudo apt install -y proton-vpn-gnome-desktop
        sudo apt update && sudo apt upgrade -y
    }; then
        rm "$protonvpn_file"
        pprint_ok "Success"
        return 0
    else
        pprint_err "Error installing ;protonvpn'"
        return 1
    fi   
}

install_docker() {
    ## Install Docker
    pprint_info "Installing Docker..."

    if is_installed "docker"; then
        return
    fi

    if {
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
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    }; then 
        # Add user to docker group for non-root user use
        sudo groupadd docker
        sudo usermod -aG docker "$USER"
        pprint_ok "Success"
        return 0
    else
        pprint_err "Error installing 'Docker'"
        return 1
    fi
}

install_wine() {
    ## Install Wine
    pprint_info "Installing wine..."

    if is_installed "wine"; then
        return
    fi

    if {
        # Enable 32-bit arch
        sudo dpkg --add-architecture i386
        # Add repos
        sudo mkdir -pm755 /etc/apt/keyrings
        sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
        # update & install
        sudo apt-get update
        sudo apt install -y --install-recommends winehq-stable
    }; then
        pprint_ok "Success!"
        return 0
    else
        pprint_err "Error installing 'wine'"
        return 1
    fi
}

install_hadolint() {
    ## Install hadolint (docker file linter)
    pprint_info "Installing hadolint..."

    if is_installed "hadolint"; then
        return
    fi

    if wget -O /tmp/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64; then
        chmod +x /tmp/hadolint
        sudo mv /tmp/hadolint /usr/local/bin/
        pprint_ok "Success"
        return 0
    else
        pprint_err "Error installing 'hadolint'"
        return 1
    fi
}

install_nix() {
    ## Install nix (nix-env, nix-shell, etc)
    pprint_info "Installing Nix..."

    if is_installed "nix" || is_installed "nix-shell"; then
        return
    fi

    # Install single-user nix; multi-user not needed
    if sh <(curl -L https://nixos.org/nix/install) --no-daemon; then
        pprint_ok "Success!"
        return 0
    else
        pprint_err "Error installing 'nix'"
        return 1
    fi
}

install_spotify() {
    ## Install Spotify
    pprint_info "Installing Spotify..."

    if is_installed "spotify"; then
        return
    fi

    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update

    if sudo apt-get install spotify-client; then
        pprint_ok "Success!"
        return 0
    else
        pprint_err "Error installing 'Spotify'"
        return 1
    fi
}

install_steam() {
    ## Install steam
    pprint_info "Installing Steam..."

    if is_installed "steam"; then
        return
    fi

    wget -O steam.deb https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb

    if sudo dpkg -i steam.deb; then
        rm steam.deb
        pprint_ok "Success!"
        return 0
    else
        pprint_err "Error installing 'steam'"
        return 1
    fi
}

install_minecraft() {
    ## Install minecraft
    pprint_info "Installing Minecraft..."

    if is_installed "minecraft-launcher"; then
        return
    fi

    wget -O minecraft.deb https://launcher.mojang.com/download/Minecraft.deb

    if sudo apt-get install libgdk-pixbuf2.0-0 && sudo dpkg -i minecraft.deb; then
        rm minecraft.deb
        pprint_ok "Success!"
        return 0
    else
        pprint_err "Error installing 'minecraft'"
        return 1
    fi
}

install_android_studio() {
    ## Install Android Studio
    pprint_info "Installing Android Studio..."

    if is_installed "android-studio"; then
        return
    fi

    if  wget -O android-studio.tar.gz https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.2.1.23/android-studio-2023.2.1.23-linux.tar.gz &&\
        sudo tar -xzvf android-studio.tar.gz -C /opt &&\
        sudo ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio &&\
        rm android-studio.tar.gz
    then
        pprint_ok "Sucess!"
        return 0
    else
        pprint_err "Error installing 'Android Studio', see output log"
        return 1
    fi
}

install_alt_btop_1_3_2() {
    # args: $1=open source repo directory to clone to and run builds from

    # Install alternative btop version than available in apt repository for repo
    # Example: Ubuntu 24.04 LTS repositories did not have v1.3.x which supports GPU monitoring

    repo_name=btop
    version=v1.3.2
    ossdir=""
    origdir=$(pwd)
    
    if [ $# -eq 0 ]; then
        pprint_info "No oss build dir specified, using /tmp";
    else
        pprint_info "Using oss build dir $1" && ossdir=$1;
    fi

    cd "$ossdir" || { pprint_err "unable to cd anywhere"; return 2; };

    git clone git@github.com:aristocratos/$repo_name.git
    cd $repo_name || { pprint_err "'$repo_name' repository did not get cloned"; return 2; }
    # Switch to desired version by tag
    git switch --detach $version

    # From btop docs: add the rocm_smi_lib as compilation dependency for GPU
    git clone https://github.com/rocm/rocm_smi_lib.git --depth 1 -b rocm-5.6.x lib/rocm_smi_lib
    # install build deps (if not installed)
    sudo apt install -y coreutils sed git build-essential gcc-11 g++-11 lowdown
    make > /dev/null
    sudo make install

    cd "$origdir" || return 2
}

install_rocm_smi() {
    # Install ROCm SMI library for AMD GPU monitoring in btop primarily (must be installed for btop to use)
    repo_name="rocm_smi_lib"
    ossdir="/tmp"
    origdir=$(pwd)

    # TODO: check if cloned already, then "git pull" changes instead

    if [ $# -eq 0 ]; then
        pprint_info "No oss build dir specified, using /tmp";
    else
        pprint_info "Using oss build dir $1" && ossdir=$1;
    fi

    cd "$ossdir" || { pprint_err "unable to cd anywhere"; return 2; };
    
    git clone git@github.com:ROCm/$repo_name.git
    cd $repo_name || { pprint_err "'$repo_name' not cloned"; return 2; }
    ## uncomment this line to build an older version
    # git switch --detach rocm-6.2.x
    mkdir -p build
    cd build || { pprint_err "Error"; return 2; }

    cmake ..
    # shellcheck disable=SC2046
    make -j $(nproc)
    # sudo make install

    cd "$origdir" || return 2
}

install_talosctl() {

    pprint_info "Installing talosctl..."

    if is_installed "talosctl"; then
        return
    fi

    if curl -sL https://talos.dev/install | sh
    then
        pprint_ok "Success!"
        return 0
    else
        pprint_err "Error installing 'talosctl'"
        return 1
    fi
}