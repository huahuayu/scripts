#!/usr/bin/env bash
# last update at: 2022-08-06
# tested in
# - [x] macos
# - [x] ubuntu
# - [x] centos
# - [ ] apline
# - [ ] archlinux

set -o errexit
set -o nounset
set -o pipefail

VERSION=${VERSION:-1.19}
ARCH=$(uname -p)

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

same_version() {
    CURRENT_VERSION=$(go env GOVERSION | sed "s/go//g")
    if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
        return 0
    fi
    return 1
}

do_install() {
    if !(has go); then
        install
    elif !(same_version); then
        install
    fi
}

install() {
    if [[ $(os) = OSX ]]; then
        if [[ $ARCH != arm ]]; then
            ARCH=amd
        fi
        wget -P /tmp https://go.dev/dl/go$VERSION.darwin-${ARCH}64.pkg
        cd /tmp && sudo installer -pkg go$VERSION.darwin-${ARCH}64.pkg -target /
        rm /tmp/go$VERSION.darwin-${ARCH}64.pkg
        output
        return 0
    fi
    if [[ $(os) == LINUX ]]; then
        if [[ $ARCH == aarch64 ]]; then
            ARCH=arm
        else
            ARCH=amd
        fi
        wget -P /tmp https://go.dev/dl/go$VERSION.linux-${ARCH}64.tar.gz
        sudo sh -c "rm -rf /usr/local/go && tar -C /usr/local -xzf /tmp/go$VERSION.linux-${ARCH}64.tar.gz"
        rm /tmp/go$VERSION.linux-${ARCH}64.tar.gz
        output
        return 0
    fi
    return 1
}

output() {
    echo "go $VERSION installed successfully, you need manually add to .*rc file:"
    cat <<'EOF'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOROOT=/usr/local/go
export PATH=$PATH:$GOBIN:$GOROOT/bin
export GO111MODULE=on
export CGO_ENABLED=1
export GOPROXY=https://goproxy.cn,direct
EOF
}

if !(has wget); then
    bash $(cd $(dirname $0) && pwd)/install-wget.sh
fi
do_install
