#!/usr/bin/env bash
set -e

export QUANTUMVIM_CONFIG_DIR="${QUANTUMVIM_CONFIG_DIR:-"$HOME/.local/config/qvim"}"
export NVIM_APPNAME="qvim"
# we should start with an empty configuration
QUANTUMVIM_CACHE_DIR="$(mktemp -d)"

export QUANTUMVIM_CACHE_DIR

echo "cache: $QUANTUMVIM_CACHE_DIR

config: $QUANTUMVIM_CONFIG_DIR"

lvim() {
  nvim -u "$QUANTUMVIM_CONFIG_DIR/lvim/tests/minimal_init.lua" --cmd "set runtimepath+=$QUANTUMVIM_CONFIG_DIR" "$@"
}

if [ -n "$1" ]; then
  lvim --headless -c "lua require('plenary.busted').run('$1')"
else
  lvim --headless -c "PlenaryBustedDirectory tests/specs { minimal_init = './tests/minimal_init.lua' }"
fi