#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

BASE_DIR=$(cd $(dirname $0) && pwd)
echo $BASE_DIR