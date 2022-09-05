#!/usr/bin/env bash
# last update at: 2022-09-01
# tested in
# - [x] macos
# - [x] ubuntu
# - [x] centos
# - [ ] apline
# - [ ] archlinux

set -o errexit
set -o nounset
set -o pipefail

os() {
    case "$OSTYPE" in
    darwin*) echo "OSX" ;;
    linux*) echo "LINUX" ;;
    *) echo "unknown os type", exit 1 ;;
    esac
}

has() {
    hash "$1" 2>/dev/null
    return $?
}

install() {
    software=$1
    if !(has $software); then
        if [[ $(os) == OSX ]]; then
            bash $(cd $(dirname $0) && pwd)/install-brew.sh
            brew install $software
            return 0
        fi
        if [[ $(os) == LINUX ]]; then
            if (has apt); then
                sudo apt update
                sudo apt install $software -y
                return 0
            fi
            if (has yum); then
                sudo yum update
                sudo yum install $software -y
                return 0
            fi
            if (has apk); then
                sudo apk update
                sudo apk add $software -y
                return 0
            fi
            if (has pacman); then
                sudo pacman -Syu
                sudo pacman -S $software -y
                return 0
            fi
        fi
        return 1
    fi
}
