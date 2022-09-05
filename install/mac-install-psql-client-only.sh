#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

brew install libpq
cd /opt/homebrew/Cellar/libpq/*/bin
sudo ln -s $PWD/psql /usr/local/bin/psql

# reference: https://stackoverflow.com/questions/44654216/correct-way-to-install-psql-without-full-postgres-on-macos
