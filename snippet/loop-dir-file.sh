#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

cd /tmp
files=(*)
for file in "${files[@]}"; do
    echo "$file"
done