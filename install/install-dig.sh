#!/usr/bin/env bash
# last updated: 2022-09-01
# tested in:
# - [ ] macos
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
    if !(has dig); then
        if [[ $(os) == OSX ]]; then
            bash $(cd $(dirname $0) && pwd)/install-brew.sh
            brew install dig
            return 0
        fi
        if [[ $(os) == LINUX ]]; then
            if (has apt); then
                sudo apt install dnsutils -y
                return 0
            fi
            if (has yum); then
                sudo yum install bind-utils -y
                return 0
            fi
            if (has apk); then
                sudo apk add bind-tools -y
                return 0
            fi
            if (has pacman); then
                sudo pacman -Ss dig -y
                return 0
            fi
        fi
        return 1
    fi
}

install
