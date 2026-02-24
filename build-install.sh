#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v node >/dev/null; then
  echo "node is required but was not found on PATH" >&2
  exit 1
fi

if ! command -v npm >/dev/null; then
  echo "npm is required but was not found on PATH" >&2
  exit 1
fi

rm -rf node_modules dist
npm install
npm run build

mkdir -p "$HOME/prj/util/bin"
ln -sfn "$PWD/dist/qmd.js" "$HOME/prj/util/bin/qmd"
chmod +x "$PWD/dist/qmd.js"

echo "Installed qmd to $HOME/prj/util/bin/qmd"
"$HOME/prj/util/bin/qmd" --help | head -n 5
