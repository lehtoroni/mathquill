#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Provide version as the first argument (patch, minor, major etc.)"
    exit 2
fi

VERSION=$1
DIST_DIR=$(mktemp -d)

# Bump version and build
npm version "$VERSION" --no-git-tag-version
make clean && make

echo "Preparing dist worktree..."

# Create worktree for dist branch
if git show-ref --verify --quiet refs/heads/dist; then
    git worktree add "$DIST_DIR" dist
else
    git worktree add -b dist "$DIST_DIR"
fi

cd "$DIST_DIR"

# Clear previous contents
git rm -rf . 2>/dev/null || true

cat > .gitignore << 'EOF'
node_modules/
*.log
EOF

# Copy artifacts
cp -r ../build .
cp ../package.json .
cp ../quickstart.html .

git add .gitignore build package.json quickstart.html
git commit -m "dist v$VERSION"

git tag -f "v$VERSION"

git push origin dist --tags

cd - >/dev/null

# Cleanup worktree
git worktree remove "$DIST_DIR"

echo "Done! Install with:"
echo "npm install github:lehtoroni/mathquill#v$VERSION"