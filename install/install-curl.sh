#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# tested in
# - [] macos
# - [x] ubuntu
# - [] centos
# - [] apline
# - [] archlinux

source $(cd $(dirname $0) && pwd)/install.sh
install curl
