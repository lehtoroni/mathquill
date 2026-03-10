#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Provide version as the first argument (patch, minor, major etc.)"
    exit 2
fi

VERSION=$1

# Bump version and build
npm version "$VERSION" --no-git-tag-version
make clean && make

npx publish-to-git --tag v$VERSION