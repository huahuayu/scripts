#!/usr/bin/env bash
# last update at: 2022-08-06
# tested in
# - [ ] macos
# - [x] ubuntu
# - [x] centos
# - [ ] apline
# - [ ] archlinux

set -o errexit
set -o nounset
set -o pipefail

has() {
    hash "$1" 2>/dev/null
    return $?
}

os() {
    case "$OSTYPE" in
    darwin*) echo "OSX" ;;
    linux*) echo "LINUX" ;;
    *) echo "unknown os type", exit 1 ;;
    esac
}

do_install() {
    USER=$(whoami)
    if !(has sudo); then
        if [[ $(os) == LINUX ]]; then
            if (has apt); then
                if [[ $USER == root ]]; then
                    apt update && apt install sudo -y
                else
                    echo "use root to execute..."
                    su root -c 'apt install sudo -y && usermod -aG sudo $USER'
                fi
                return 0
            fi
            if (has yum); then
                if [[ $USER == root ]]; then
                    yum update && yum install sudo -y
                else
                    echo "use root to execute..."
                    su root -c 'yum install sudo -y && usermod -aG sudo $USER'
                fi
                return 0
            fi
            if (has pacman); then
                sudo pacman -S sudo -y
                if [[ $USER == root ]]; then
                    pacman -S sudo -y
                else
                    echo "use root to execute..."
                    su root -c 'pacman -S sudo -y && usermod -aG sudo $USER'
                fi
                return 0
            fi
        fi
        return 1
    fi
}

do_install

echo "sudo install successful, logout & login to take effect."
