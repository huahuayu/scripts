#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

VERSION=${VERSION:-1.18.4}
ARCH=$(uname -p)

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

.$(dirname $0)/install-wget

do_install() {
    if !(has go); then
        rm /tmp/go$VERSION.*.pkg
        if [[ $(os) = OSX ]]; then
            if [[ $ARCH -eq "arm" ]]; then
                wget -P /tmp https://go.dev/dl/go$VERSION.darwin-arm64.pkg
            else
                wget -P /tmp https://go.dev/dl/go$VERSION.darwin-amd64.pkg
            fi
            cd /tmp && sudo installer -pkg go$VERSION.darwin-*.pkg -target /
            return 0
        fi
        if [[ $(os) -eq LINUX ]]; then
            if [[ $ARCH -eq "aarch64" ]]; then
                wget -P /tmp https://go.dev/dl/go$VERSION.linux-arm64.tar.gz
            else
                wget -P /tmp https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
            fi
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go$VERSION.linux-*.tar.gz
            return 0
        fi
        return 1
    fi
}

echo "add to PATH by: export PATH=$PATH:/usr/local/go/bin"

do_install
