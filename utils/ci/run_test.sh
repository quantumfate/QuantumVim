#!/usr/bin/env bash
set -e

export QV_FIRST_TIME_SETUP=1
export QUANTUMVIM_CONFIG_DIR="${QUANTUMVIM_CONFIG_DIR:-"$HOME/.local/config/qvim"}"
export NVIM_APPNAME="qvim"
# we should start with an empty configuration
QUANTUMVIM_CACHE_DIR="$(mktemp -d)"

export QUANTUMVIM_CACHE_DIR

echo "cache: $QUANTUMVIM_CACHE_DIR

config: $QUANTUMVIM_CONFIG_DIR"

qvim() {
  nvim -u "$QUANTUMVIM_CONFIG_DIR/tests/minimal_init.lua" --cmd "set runtimepath+=$QUANTUMVIM_CONFIG_DIR" "$@"
}

if [ -n "$1" ]; then
  qvim --headless -c "lua require('plenary.busted').run('$1')"
else
  qvim --headless -c "PlenaryBustedDirectory tests/specs { minimal_init = './tests/minimal_init.lua' }"
fi