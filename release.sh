#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Provide version as the first argument (patch, minor, major etc.)"
    exit 2
fi

VERSION=$1
make
# Publish NPM package
#yarn publish "--$VERSION"
#git push --follow-tags

# Publish gh-pages
#git checkout gh-pages
#git reset --hard master
#git add -f build
#git commit -m "Add distributable files for latest version"
#git push -f
#git checkout -

#!/bin/bash
# scripts/publish-dist.sh

# "Publish" into a separate branch/tag
echo "Switching to dist branch..."
git checkout dist 2>/dev/null || git checkout --orphan dist

# Bring in only the needed files from master
git checkout master -- build/ package.json quickstart.html

git add build/ package.json quickstart.html
git commit -m "dist v$VERSION"
git tag "v$VERSION" 2>/dev/null || echo "Tag already exists, skipping"

git push origin dist --tags

echo "Done! Install with: npm install github:lehtoroni/mathquill#v$VERSION"
git checkout master

