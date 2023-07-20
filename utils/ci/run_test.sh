#!/usr/bin/env bash
set -e

export QV_FIRST_TIME_SETUP=1
export QUANTUMVIM_CONFIG_DIR="${QUANTUMVIM_CONFIG_DIR:-"$HOME/.config/qvim"}"
export NVIM_APPNAME="${NVIM_APPNAME:-"qvim"}"

QUANTUMVIM_CACHE_DIR="$(mktemp -d)"
QUANTUMVIM_STATE_DIR="$(mktemp -d)"
QUANTUMVIM_DATA_DIR="$(mktemp -d)"

export QUANTUMVIM_CACHE_DIR QUANTUMVIM_STATE_DIR QUANTUMVIM_DATA_DIR

echo "cache: $QUANTUMVIM_CACHE_DIR"
echo "state: $QUANTUMVIM_STATE_DIR"
echo "data: $QUANTUMVIM_DATA_DIR"
echo "config: $QUANTUMVIM_CONFIG_DIR"


mkdir -p "$QUANTUMVIM_STATE_DIR/after/pack/lazy/opt"
git clone https://github.com/nvim-lua/plenary.nvim.git "$QUANTUMVIM_STATE_DIR/after/pack/lazy/opt/plenary"

qvim() {
  exec -a qvim nvim -u "$QUANTUMVIM_CONFIG_DIR/tests/minimal_init.lua" \
     --cmd "set runtimepath+=$QUANTUMVIM_STATE_DIR/after/pack/lazy/opt/plenary" \
    "$@"
}

if [ -n "$1" ]; then
  qvim --headless -c "lua require('plenary.busted').run('$1')"
else
  qvim --headless -c "PlenaryBustedDirectory tests/specs { minimal_init = './tests/minimal_init.lua' }"
fi
