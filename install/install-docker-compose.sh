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
        if [[ $(os) -eq OSX ]]; then
            .$(dirname $0)/install-brew
            brew cask install docker
            return 0
        fi
        if [[ $(os) -eq LINUX ]]; then
            .$(dirname $0)/install-wget
            wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
            sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
            sudo chmod -v +x /usr/local/bin/docker-compose
            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
            return 0
        fi
        return 1
    fi
}

do_install
