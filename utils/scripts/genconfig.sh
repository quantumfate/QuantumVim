#!/usr/bin/env bash
set -eo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"

QUANTUMVIM_DIR="${QUANTUMVIM_DIR:-"$XDG_CONFIG_HOME/qvim"}"
QUANTUMVIM_CACHE_DIR="${QUANTUMVIM_CACHE_DIR:-"$XDG_CACHE_HOME/qvim"}"

QV_PLUGIN_CONFIG_DIR="${QV_PLUGIN_CONFIG_DIR:-"$QUANTUMVIM_DIR"/lua/qvim/integrations}"

PLUGIN_NAME=$1

function generate_plugin_config_file() {
    
  [ ! -d "$QV_PLUGIN_CONFIG_DIR" ] && mkdir -p "$QV_PLUGIN_CONFIG_DIR"
  
  local src="$QUANTUMVIM_DIR/utils/scripts/templates/plugin.lua.template"
  local dst="$QV_PLUGIN_CONFIG_DIR/$PLUGIN_NAME.lua"

  if [ -f "$dst" ]; then
    mv "$dst" "$dst".old
  fi

  cp "$src" "$dst"
  # Replace - with _ 
  PLUGIN_NAME="${PLUGIN_NAME//-/_}"
  sed -e s"#QV_PLUGIN_NAME_VAR#${PLUGIN_NAME}#"g "$src" \
    | tee "$dst" >/dev/null
}

generate_plugin_config_file

echo "Plugin config file generated"

exit 0