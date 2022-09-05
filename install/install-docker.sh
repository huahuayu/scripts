#!/usr/bin/env bash
# last updated: 2022-09-05
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

os() {
    case "$OSTYPE" in
    darwin*) echo "OSX" ;;
    linux*) echo "LINUX" ;;
    *) echo "unknown os type", exit 1 ;;
    esac
}

do_install() {
    if !(has docker); then
        if [[ $(os) = OSX ]]; then
            bash $(cd $(dirname $0) && pwd)/install-brew.sh
            brew cask install docker
            return 0
        fi
        if [[ $(os) = LINUX ]]; then
            if !(has curl); then
                bash $(cd $(dirname $0) && pwd)/install-curl.sh
            fi
            curl -s https://get.docker.com | bash
            return 0
        fi
        return 1
    fi
}

do_install

if [[ $(os) == LINUX ]]; then
    read -r -p "Specify a datadir for docker if you want (optional): " datadir
    if [[ -d $datadir ]]; then
        sudo mkdir -p $datadir
    fi
    sudo sh -c 'cat >/etc/docker/daemon.json <<EOF
{
    "data-root": "datadir"
}
EOF'
    sudo sh -c 'sed -i "s/datadir/$datadir/g" /etc/docker/daemon.json'
    echo "note: you'll need to log out and log in again for this change to take effect."
fi

while true; do
    read -r -p "Do you want to run docker by non-root user? (y/n) " input

    case $input in
    [yY][eE][sS] | [yY])
        sudo usermod -a -G docker $(whoami)
        echo "$(whoami) is added to docker group"
        break
        ;;
    [nN][oO] | [nN])
        break
        ;;
    *)
        echo "Invalid input (y/n)..."
        ;;
    esac
done

sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker
