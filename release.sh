#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Provide version as the first argument (patch, minor, major etc.)"
    exit 2
fi

VERSION=$1
DIST_DIR=$(mktemp -d)
REPO_ROOT=$(git rev-parse --show-toplevel)

# Bump version and build
npm version "$VERSION" --no-git-tag-version
make clean && make

echo "Preparing dist worktree..."

if git show-ref --verify --quiet refs/heads/dist; then
    git worktree add "$DIST_DIR" dist
else
    git worktree add -b dist "$DIST_DIR"
fi

cd "$DIST_DIR"

git rm -rf . 2>/dev/null || true

cat > .gitignore << 'EOF'
node_modules/
*.log
EOF

# Copy build artifacts from repo root
cp -r "$REPO_ROOT/build" .
cp "$REPO_ROOT/package.json" .
cp "$REPO_ROOT/quickstart.html" .

git add .gitignore build package.json quickstart.html
git commit -m "dist v$VERSION"

git tag -f "v$VERSION"
git push origin dist --tags

cd >/dev/null

git worktree remove "$DIST_DIR"

echo "Done! Install with:"
echo "npm install github:lehtoroni/mathquill#v$VERSION"