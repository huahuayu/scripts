#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

echo $(uname -s) $(uname -m)

# uname -s output
# Linux
# Darwin

# uname -m output
# x86_64
# aarch64
# arm

# example
# wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
