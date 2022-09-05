#!/usr/bin/env bash
# last updated: 2022-08-06
# tested in:
# - [x] macos

set -o errexit
set -o nounset
set -o pipefail

has() {
    hash "$1" 2>/dev/null
    return $?
}

if !(has brew); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
