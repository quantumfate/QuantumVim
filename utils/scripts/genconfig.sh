#!/usr/bin/env bash
set -eo pipefail

PLUGIN_NAME=""
EXT=""
IS_PARENT=false
while getopts ":p:e:t" opt; do
  case $opt in
    p)
      PLUGIN_NAME="$OPTARG"
      ;;
    e)
      EXT="$OPTARG"
      ;;
    t)
      IS_PARENT=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"

QUANTUMVIM_DIR="${QUANTUMVIM_DIR:-"$XDG_CONFIG_HOME/qvim"}"
QUANTUMVIM_CACHE_DIR="${QUANTUMVIM_CACHE_DIR:-"$XDG_CACHE_HOME/qvim"}"

QV_PLUGIN_CONFIG_DIR="${QV_PLUGIN_CONFIG_DIR:-"$QUANTUMVIM_DIR"/lua/qvim/integrations}"
QV_LAZY_PLUGIN_SPEC_DIR="${QV_LAZY_PLUGIN_SPEC_DIR:-"$QV_PLUGIN_CONFIG_DIR"/loader/spec/config}"

QV_PLUGIN_PARENT_DIR="${QV_PLUGIN_PARENT_DIR:-"$QV_PLUGIN_CONFIG_DIR"/"$PLUGIN_NAME"}"

function generate_plugin_config_file() {
    
  [ ! -d "$QV_PLUGIN_CONFIG_DIR" ] && mkdir -p "$QV_PLUGIN_CONFIG_DIR"

  local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/plugin.lua.template"
  local src_spec="$QUANTUMVIM_DIR/utils/scripts/templates/spec.lua.template"
  local dst_spec="$QV_LAZY_PLUGIN_SPEC_DIR/config_$PLUGIN_NAME.lua"

  local ITERATIONS=2
  if [[ -n "$PLUGIN_NAME"  && -n "$EXT" && "$IS_PARENT" == "false" ]]; then
    mkdir -p "${QV_PLUGIN_PARENT_DIR}"
    # Create an extension in an existing parent
    local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/extension.lua.template"
    local dst_plugin="${QV_PLUGIN_PARENT_DIR}/${EXT}.lua"
    if [ -f "$dst_spec" ]; then
      ITERATIONS=1
      local sources=("$src_plugin")
      local destinations=("$dst_plugin")
    else
      local sources=("$src_plugin" "$src_spec")
      local destinations=("$dst_plugin" "$dst_spec")
    fi
    
  elif [[  -n "$PLUGIN_NAME" && "$IS_PARENT" == "true" && -z "$EXT" ]]; then
    # Create a parent folder 
    mkdir -p "${QV_PLUGIN_PARENT_DIR}"
    local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/init.lua.template"
    local dst_plugin="${QV_PLUGIN_PARENT_DIR}/init.lua"
    local sources=("$src_plugin" "$src_spec")
    local destinations=("$dst_plugin" "$dst_spec")
  elif [[ -n "$PLUGIN_NAME" && "$IS_PARENT" == "true" && -n "$EXT" ]]; then
    # make parent with extension
    mkdir -p "${QV_PLUGIN_PARENT_DIR}"
    local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/init.lua.template"
    local src_ext="$QUANTUMVIM_DIR/utils/scripts/templates/extension.lua.template"
    local dst_plugin="${QV_PLUGIN_PARENT_DIR}/init.lua"
    local dst_ext="${QV_PLUGIN_PARENT_DIR}/${EXT}.lua"
    local sources=("$src_plugin" "$src_ext" "$src_spec")
    local destinations=("$dst_plugin" "$dst_ext" "$dst_spec")
    ITERATIONS=3
  else
    # Normal plugin
    local dst_plugin="$QV_PLUGIN_CONFIG_DIR/$PLUGIN_NAME.lua"
    local sources=("$src_plugin" "$src_spec")
    local destinations=("$dst_plugin" "$dst_spec")
  fi
 
  
  PLUGIN_NAME_STRING=$PLUGIN_NAME
  PLUGIN_NAME="${PLUGIN_NAME//-/_}"
  EXT_STRING=$EXT
  EXT="${EXT//-/_}" 

  for (( i=0; i<ITERATIONS; i++ )); do
    if [ -f "${destinations[i]}" ]; then
      mv "${destinations[i]}" "${destinations[i]}".old
    fi

    cp "${sources[i]}" "${destinations[i]}"

    sed -e s"#QV_STRING_EXT_PLUGIN_NAME_VAR#${EXT_STRING}#"g \
        -e s"#QV_EXT_PLUGIN_VAR#${EXT}#"g \
        -e s"#QV_STRING_PLUGIN_NAME_VAR#${PLUGIN_NAME_STRING}#"g \
        -e s"#QV_PLUGIN_NAME_VAR#${PLUGIN_NAME}#"g "${sources[i]}" \
        | tee "${destinations[i]}" >/dev/null

  done

}

generate_plugin_config_file

echo "Plugin config file generated. Remember to add the plugin to the configuration and to the lazy table."

exit 0