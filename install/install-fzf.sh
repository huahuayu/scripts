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

has() {
    hash "$1" 2>/dev/null
    return $?
}

if !(has git); then
    bash $(cd $(dirname $0) && pwd)/install-git.sh
fi

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
