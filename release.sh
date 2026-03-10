#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Provide version as the first argument (patch, minor, major etc.)"
    exit 2
fi

VERSION=$1

# Bump version in package.json and build
npm version $VERSION --no-git-tag-version
make clean && make

cp -r build/ /tmp/mq-build-$$
cp package.json /tmp/mq-package-$$.json
cp quickstart.html /tmp/mq-quickstart-$$.html

# "Publish" into a separate branch/tag
echo "Switching to dist branch..."
git checkout dist 2>/dev/null || git checkout -b dist

# On orphan branch, remove everything;
git rm -rf . 2>/dev/null || true

cat > .gitignore << 'EOF'
node_modules/
*.log
EOF

# Restore from temp
mv /tmp/mq-build-$$ ./build
cp /tmp/mq-package-$$.json ./package.json
cp /tmp/mq-quickstart-$$.html ./quickstart.html

# Add the required files
git add .gitignore build/ package.json quickstart.html
git commit -m "dist v$VERSION"
git tag "v$VERSION" 2>/dev/null || echo "Tag already exists, skipping"

git push origin dist --tags

# Cleanup
rm -rf /tmp/mq-build-$$ /tmp/mq-package-$$.json /tmp/mq-quickstart-$$.html

echo "Done! Install with: npm install github:lehtoroni/mathquill#v$VERSION"
git checkout master

