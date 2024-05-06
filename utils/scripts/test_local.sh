#!/usr/bin/env bash
set -e

export XDG_STATE_HOME="$HOME/.local/state"
export XDG_LOG_HOME="$HOME/.local/log"

export QV_FIRST_TIME_SETUP=1
export NVIM_APPNAME="${NVIM_APPNAME:-"qvim"}"

QUANTUMVIM_LOG_DIR="$(mktemp -d)"
QUANTUMVIM_STATE_DIR="$(mktemp -d)"
QUANTUMVIM_RTP_DIR="${QUANTUMVIM_RTP_DIR:-"$QUANTUMVIM_STATE_DIR/$NVIM_APPNAME"}"
QUANTUMVIM_CONFIG_DIR="$(mktemp -d)"
QUANTUMVIM_CACHE_DIR="$(mktemp -d)"
QUANTUMVIM_DATA_DIR="$(mktemp -d)"

QUANTUMVIM_PACK_DIR="${QUANTUMVIM_PACK_DIR:-"${QUANTUMVIM_RTP_DIR}/after/pack/lazy/opt"}"
QUANTUMVIM_STRUCTLOG_DIR="${QUANTUMVIM_STRUCTLOG_DIR:-"${QUANTUMVIM_PACK_DIR}/structlog"}"

export XDG_STATE_HOME=$QUANTUMVIM_STATE_DIR
export XDG_CONFIG_HOME=$QUANTUMVIM_CONFIG_DIR
export XDG_DATA_HOME=$QUANTUMVIM_DATA_DIR
export XDG_LOG_HOME=$QUANTUMVIM_LOG_DIR
export XDG_CACHE_HOME=$QUANTUMVIM_CACHE_DIR

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

if [ ! -d "$QUANTUMVIM_STRUCTLOG_DIR" ]; then
    mkdir -p "$QUANTUMVIM_STRUCTLOG_DIR"
    git clone https://github.com/Tastyep/structlog.nvim.git "$QUANTUMVIM_STRUCTLOG_DIR"
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
