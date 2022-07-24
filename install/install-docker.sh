#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

os() {
    case "$OSTYPE" in
    darwin*) echo "OSX" ;;
    linux*) echo "LINUX" ;;
    *) echo "unknown: $OSTYPE", exit 1 ;;
    esac
}

has() {
    hash "$1" 2>/dev/null
    return $?
}

do_install() {
    if !(has docker); then
        if [[ $(os) = OSX ]]; then
            .$(dirname $0)/install-brew
            brew cask install docker
            return 0
        fi
        if [[ $(os) = LINUX ]]; then
            .$(dirname $0)/install-curl
            curl -s https://get.docker.com | bash
            return 0
        fi
        return 1
    fi
}

do_install
