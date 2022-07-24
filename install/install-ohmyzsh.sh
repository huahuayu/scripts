#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

.$(dirname $0)/install-zsh.sh
if ![[ -d $HOME/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
