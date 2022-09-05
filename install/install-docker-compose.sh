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

do_install() {
    if !(has docker-compose); then
        if [[ $(os) == LINUX ]]; then
            bash $(cd $(dirname $0) && pwd)/install-wget.sh
            wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
            sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
            sudo chmod -v +x /usr/local/bin/docker-compose
            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
            return 0
        fi
        return 1
    fi
}

bash $(cd $(dirname $0) && pwd)/install-docker.sh
do_install
