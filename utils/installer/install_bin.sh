#!/usr/bin/env bash
set -eo pipefail

INSTALL_PREFIX="${INSTALL_PREFIX:-"$HOME/.local"}"

NVIM_APPNAME="qvim"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
XDG_STATE_HOME="${XDG_STATE_HOME:-"$HOME/.local/state"}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"


QUANTUMVIM_CONFIG_DIR="${QUANTUMVIM_CONFIG_DIR:-"$XDG_CONFIG_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_DATA_DIR="${QUANTUMVIM_DATA_DIR:-"$XDG_DATA_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_STATE_DIR="${QUANTUMVIM_STATE_DIR:-"$XDG_STATE_HOME/$NVIM_APPNAME"}"
QUANTUMVIM_CACHE_DIR="${QUANTUMVIM_CACHE_DIR:-"$XDG_CACHE_HOME/$NVIM_APPNAME"}"

function setup_qvim() {
  local src="$QUANTUMVIM_CONFIG_DIR/utils/bin/${NVIM_APPNAME}.template"
  local dst="$INSTALL_PREFIX/bin/${NVIM_APPNAME}"

  [ ! -d "$INSTALL_PREFIX/bin" ] && mkdir -p "$INSTALL_PREFIX/bin"

  # remove outdated installation so that `cp` doesn't complain
  rm -f "$dst"

  cp "$src" "$dst"

  sed -e s"#CONFIG_DIR_VAR#\"${QUANTUMVIM_CONFIG_DIR}\"#"g \
    -e s"#DATA_DIR_VAR#\"${QUANTUMVIM_DATA_DIR}\"#"g \
    -e s"#STATE_DIR_VAR#\"${QUANTUMVIM_STATE_DIR}\"#"g \
    -e s"#CACHE_DIR_VAR#\"${QUANTUMVIM_CACHE_DIR}\"#"g \
    -e s"#APPNAME_VAR#\"${NVIM_APPNAME}\"#"g \ "$src" \
    | tee "$dst" >/dev/null

  chmod u+x "$dst"
}

setup_qvim "$@"

echo "You can start QuantumVim by running: $INSTALL_PREFIX/bin/$NVIM_APPNAME"
