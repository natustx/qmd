#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# --- Activate the Node version from .nvmrc via nvm ---
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "nvm not found at $NVM_DIR/nvm.sh" >&2
  exit 1
fi
source "$NVM_DIR/nvm.sh"
nvm install  # reads .nvmrc, installs if missing, activates

NODE_BIN="$(command -v node)"
NODE_VER="$(node --version)"
MAJOR="${NODE_VER#v}"; MAJOR="${MAJOR%%.*}"
if (( MAJOR < 22 || MAJOR >= 25 )); then
  echo "Node $NODE_VER is outside engines range (>=22 <25)" >&2
  exit 1
fi
echo "Building with Node $NODE_VER ($NODE_BIN)"

# --- Build ---
rm -rf node_modules dist
npm install
npm run build

# --- Install wrapper script pinned to this Node binary ---
NODE_ABS="$(realpath "$NODE_BIN")"
QMD_JS="$PWD/dist/qmd.js"

mkdir -p "$HOME/prj/util/bin"
rm -f "$HOME/prj/util/bin/qmd"
cat > "$HOME/prj/util/bin/qmd" <<WRAPPER
#!/bin/bash
exec "$NODE_ABS" "$QMD_JS" "\$@"
WRAPPER
chmod +x "$HOME/prj/util/bin/qmd"

echo "Installed qmd to $HOME/prj/util/bin/qmd (Node $NODE_VER)"
"$HOME/prj/util/bin/qmd" --help | head -n 5
