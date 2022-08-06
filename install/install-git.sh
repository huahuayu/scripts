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

source $(cd $(dirname $0) && pwd)/install.sh
install git
