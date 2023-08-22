#!/usr/bin/env bash
set -eo pipefail

qvim_state_name="quantumvim"
INSTALL_PREFIX="${INSTALL_PREFIX:-"$HOME/.local"}"

NVIM_APPNAME="${NVIM_APPNAME:-"qvim"}"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
XDG_STATE_HOME="${XDG_STATE_HOME:-"$HOME/.local/state"}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"
XDG_LOG_HOME="${XDG_LOG_HOME:-"$HOME/.local/log"}"

QUANTUMVIM_LOG_DIR="${QUANTUMVIM_LOG_DIR:-"$XDG_LOG_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_CONFIG_DIR="${QUANTUMVIM_CONFIG_DIR:-"$XDG_CONFIG_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_DATA_DIR="${QUANTUMVIM_DATA_DIR:-"$XDG_DATA_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_STATE_DIR="${QUANTUMVIM_STATE_DIR:-"$XDG_STATE_HOME/$qvim_state_name"}"
QUANTUMVIM_RTP_DIR="${QUANTUMVIM_RTP_DIR:-"$QUANTUMVIM_STATE_DIR/$NVIM_APPNAME"}"
QUANTUMVIM_CACHE_DIR="${QUANTUMVIM_CACHE_DIR:-"$XDG_CACHE_HOME/$NVIM_APPNAME"}"

QUANTUMVIM_PACK_DIR="${QUANTUMVIM_DATA_PROFILE}/after/pack/lazy/opt"
QUANTUMVIM_STRUCTLOG_DIR="${QUANTUMVIM_PACK_DIR}/structlog"

function setup_qvim() {
    local src="$QUANTUMVIM_RTP_DIR/utils/bin/${NVIM_APPNAME}.template"
    local dst="$INSTALL_PREFIX/bin/${NVIM_APPNAME}"

    [ ! -d "$INSTALL_PREFIX/bin" ] && mkdir -p "$INSTALL_PREFIX/bin"

    # remove outdated installation so that `cp` doesn't complain
    rm -f "$dst"

    cp "$src" "$dst"

    sed -e s"#CONFIG_DIR_VAR#\"${QUANTUMVIM_CONFIG_DIR}\"#"g \
        -e s"#LOG_DIR_VAR#\"${QUANTUMVIM_LOG_DIR}\"#"g \
        -e s"#PACK_DIR_VAR#\"${QUANTUMVIM_PACK_DIR}\"#"g \
        -e s"#STRUCTLOG_DIR_VAR#\"${QUANTUMVIM_STRUCTLOG_DIR}\"#"g \
        -e s"#DATA_DIR_VAR#\"${QUANTUMVIM_DATA_DIR}\"#"g \
        -e s"#STATE_DIR_VAR#\"${QUANTUMVIM_STATE_DIR}\"#"g \
        -e s"#RTP_DIR_VAR#\"${QUANTUMVIM_RTP_DIR}\"#"g \
        -e s"#CACHE_DIR_VAR#\"${QUANTUMVIM_CACHE_DIR}\"#"g \
        -e s"#APPNAME_VAR#\"${NVIM_APPNAME}\"#"g "$src" \
        | tee "$dst" >/dev/null

    chmod u+x "$dst"
}

setup_qvim "$@"

echo "You can start QuantumVim by running: $INSTALL_PREFIX/bin/$NVIM_APPNAME"
