#!/usr/bin/env bash
# tested in
# - [] macos
# - [x] ubuntu
# - [] centos
# - [] apline
# - [] archlinux

set -o errexit
set -o nounset
set -o pipefail

source $(cd $(dirname $0) && pwd)/install.sh
install wget
