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
# /exec-daemon/node) so the repo-pinned Node version is actually used. $NVM_BIN
# is set by `nvm use` to the active version's bin dir, so it is not poisoned by
# a shim already on PATH (unlike `nvm which current`).
export PATH="$NVM_BIN:$PATH"

corepack enable pnpm

pnpm install --frozen-lockfile
