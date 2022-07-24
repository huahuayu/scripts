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

install() {
    software=$1
    if !(has $software); then
        if [[ $(os) -eq OSX ]]; then
            .$(dirname $0)/install-brew
            brew install $software
            return 0
        fi
        if [[ $(os) -eq LINUX ]]; then
            if (has apt-get); then
                sudo apt-get install $software -y
                return 0
            fi
            if (has yum); then
                sudo yum install $software -y
                return 0
            fi
            if (has pacman); then
                sudo pacman -S $software -y
                return 0
            fi
        fi
        return 1
    fi
}
