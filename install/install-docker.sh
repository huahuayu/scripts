#!/usr/bin/env bash
# last updated: 2022-08-06
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

do_install() {
    if !(has docker); then
        if [[ $(os) = OSX ]]; then
            bash $(cd $(dirname $0) && pwd)/install-brew
            brew cask install docker
            return 0
        fi
        if [[ $(os) = LINUX ]]; then
            if !(has curl); then
                bash $(cd $(dirname $0) && pwd)/install-curl
            fi
            curl -s https://get.docker.com | bash
            return 0
        fi
        return 1
    fi
}

do_install
