#!/bin/bash
set -e
cd /home/openclaw/.openclaw/workspace/bitstrike-godot

# Export
godot --headless --export-release "Web" 2>&1 | tail -2

# Cache bust
cd export/web
VERSION=$(date +%s)

# Clean old versioned files
rm -f index.[0-9]*.wasm index.[0-9]*.pck index.[0-9]*.js

# Copy with version
cp index.wasm "index.${VERSION}.wasm" 2>/dev/null || true
cp index.pck "index.${VERSION}.pck" 2>/dev/null || true  
cp index.js "index.${VERSION}.js" 2>/dev/null || true

# Update references
sed -i "s/index\.wasm/index.${VERSION}.wasm/g" index.html
sed -i "s/index\.pck/index.${VERSION}.pck/g" index.html  
sed -i "s/\"index\.js\"/\"index.${VERSION}.js\"/g" index.html
sed -i "s/index\.wasm/index.${VERSION}.wasm/g" "index.${VERSION}.js"
sed -i "s/index\.pck/index.${VERSION}.pck/g" "index.${VERSION}.js"

rm -f index.wasm index.pck index.js

# Push
rm -rf .git
git init -b gh-pages
git add -A
git commit -m "build ${VERSION}" --quiet
git remote add origin https://github.com/Bender21m/bitstrike-godot.git
git push -f origin gh-pages --quiet 2>&1

echo "Deployed build ${VERSION}"
