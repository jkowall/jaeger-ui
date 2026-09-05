#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for Jaeger UI.
# Ensures the repo-pinned Node version (see .nvmrc) is active, enables the
# pinned pnpm via corepack, then installs workspace dependencies.
set -euo pipefail

cd "$(dirname "$0")/.."

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Install nvm if it is not already present in the base image.
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -fsSL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"

# Install and select the Node version pinned in .nvmrc.
nvm install
nvm use

# Force the nvm-provided Node ahead of any runtime-injected node shim (e.g.
# /exec-daemon/node) so the repo-pinned Node version is actually used. The bin
# dir is derived from the active nvm version directly (not via PATH lookup, which
# the shim would otherwise poison).
export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"

corepack enable pnpm

pnpm install --frozen-lockfile
