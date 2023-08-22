#!/usr/bin/env bash
set -e

qvim_state_name="quantumvim"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_LOG_HOME="$HOME/.local/log"

export QV_FIRST_TIME_SETUP=1
export NVIM_APPNAME="${NVIM_APPNAME:-"qvim"}"

QUANTUMVIM_LOG_DIR="${QUANTUMVIM_LOG_DIR:-"$XDG_LOG_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_STATE_DIR="${QUANTUMVIM_STATE_DIR:-"$XDG_STATE_HOME/$qvim_state_name"}"
QUANTUMVIM_RTP_DIR="${QUANTUMVIM_RTP_DIR:-"$QUANTUMVIM_STATE_DIR/$NVIM_APPNAME"}"
QUANTUMVIM_CONFIG_DIR="${QUANTUMVIM_CONFIG_DIR:-"$XDG_CONFIG_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_CACHE_DIR="$(mktemp -d)"
QUANTUMVIM_DATA_DIR="$(mktemp -d)"

QUANTUMVIM_PACK_DIR="${QUANTUMVIM_PACK_DIR:-"${QUANTUMVIM_RTP_DIR}/after/pack/lazy/opt"}"
QUANTUMVIM_STRUCTLOG_DIR="${QUANTUMVIM_STRUCTLOG_DIR:-"${QUANTUMVIM_PACK_DIR}/structlog"}"


export QUANTUMVIM_CACHE_DIR QUANTUMVIM_STATE_DIR QUANTUMVIM_DATA_DIR QUANTUMVIM_CONFIG_DIR QUANTUMVIM_RTP_DIR QUANTUMVIM_LOG_DIR QUANTUMVIM_PACK_DIR QUANTUMVIM_STRUCTLOG_DIR

echo "state: $QUANTUMVIM_STATE_DIR"
echo "rtp: $QUANTUMVIM_RTP_DIR"
echo "cache: $QUANTUMVIM_CACHE_DIR"
echo "data: $QUANTUMVIM_DATA_DIR"
echo "config: $QUANTUMVIM_CONFIG_DIR"
echo "log: $QUANTUMVIM_LOG_DIR"

if [ ! -d "$QUANTUMVIM_RTP_DIR/after/pack/lazy/opt/plenary" ]; then
    mkdir -p "$QUANTUMVIM_RTP_DIR/after/pack/lazy/opt"
    git clone https://github.com/nvim-lua/plenary.nvim.git "$QUANTUMVIM_RTP_DIR/after/pack/lazy/opt/plenary"
fi

qvim() {
    exec -a qvim nvim -u "$QUANTUMVIM_RTP_DIR/tests/minimal_init.lua" \
        --cmd "set runtimepath+=$QUANTUMVIM_RTP_DIR/after/pack/lazy/opt/plenary" \
        "$@"
}

if [ -n "$1" ]; then
    qvim --headless -c "lua require('plenary.busted').run('$1')"
else
    qvim --headless -c "PlenaryBustedDirectory tests/specs { minimal_init = './tests/minimal_init.lua' }"
fi
