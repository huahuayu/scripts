#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

source $(dirname $0)/install.sh
install git
