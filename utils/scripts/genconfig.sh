#!/usr/bin/env bash
set -eo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"

QUANTUMVIM_DIR="${QUANTUMVIM_DIR:-"$XDG_CONFIG_HOME/qvim"}"
QUANTUMVIM_CACHE_DIR="${QUANTUMVIM_CACHE_DIR:-"$XDG_CACHE_HOME/qvim"}"

QV_PLUGIN_CONFIG_DIR="${QV_PLUGIN_CONFIG_DIR:-"$QUANTUMVIM_DIR"/lua/qvim/integrations}"
QV_LAZY_PLUGIN_SPEC_DIR="${QV_LAZY_PLUGIN_SPEC_DIR:-"$QV_PLUGIN_CONFIG_DIR"/loader/spec/config}"

PLUGIN_NAME=$1

function generate_plugin_config_file() {
    
  [ ! -d "$QV_PLUGIN_CONFIG_DIR" ] && mkdir -p "$QV_PLUGIN_CONFIG_DIR"
  
  local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/plugin.lua.template"
  local dst_plugin="$QV_PLUGIN_CONFIG_DIR/$PLUGIN_NAME.lua"
  local src_spec="$QUANTUMVIM_DIR/utils/scripts/templates/spec.lua.template"
  local dst_spec="$QV_LAZY_PLUGIN_SPEC_DIR/$PLUGIN_NAME.lua"
  
  local sources=("$src_plugin" "$src_spec")
  local destinations=("$dst_plugin" "$dst_spec")
  
  PLUGIN_NAME_STRING=$PLUGIN_NAME
  PLUGIN_NAME="${PLUGIN_NAME//-/_}"

  for (( i=0; i<2; i++ )); do
    if [ -f "${destinations[i]}" ]; then
      mv "${destinations[i]}" "${destinations[i]}".old
    fi

    cp "${sources[i]}" "${destinations[i]}"

    sed -e s"#QV_STRING_PLUGIN_NAME_VAR#${PLUGIN_NAME_STRING}#"g \
      -e s"#QV_PLUGIN_NAME_VAR#${PLUGIN_NAME}#"g "${sources[i]}" \
      | tee "${destinations[i]}" >/dev/null

    if [ "$i" -lt 1 ]; then
      echo "Generated plugin file."
    else
      echo "Generated spec file."
    fi
  done

}

generate_plugin_config_file

echo "Plugin config file generated. Remember to add the plugin to the configuration and to the lazy table."

exit 0