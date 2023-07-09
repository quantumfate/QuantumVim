#!/usr/bin/env bash
set -eo pipefail

function validate_plugin_name() {
    # check the plugin name against patterns
    local plugin="$1"
    if [[ "$plugin" =~ ^[[:alnum:]_-]+/([[:alnum:]_-]+)\.nvim$ ]]; then
        plugin_name=${BASH_REMATCH[1]}
    elif [[ "$plugin" =~ ^[[:alnum:]_-]+/([[:alnum:]_-]+)\.lua$ ]]; then
        plugin_name=${BASH_REMATCH[1]}
    elif [[ "$plugin" =~ ^[[:alnum:]_-]+/([[:alnum:]_-]+)$ ]]; then
        plugin_name=${BASH_REMATCH[1]}
    else
        echo "Invalid plugin name: $plugin" >&2
        exit 1
    fi

    # special pattern
    if [[ "$plugin_name" == "nvim" ]]; then
        if [[ "$plugin" =~ ^([[:alnum:]_-]+)/nvim$ ]]; then
            plugin_name=${BASH_REMATCH[1]}
            plugin_name=${plugin_name//nvim/}
        fi
    fi

    # normalize plugin name
    if [ -n "$plugin_name" ]; then
        plugin_name=${plugin_name//--/-}
        hr_name=$plugin_name
        plugin_name=${plugin_name//-/_}
        plugin_name=${plugin_name,,}
    else
        echo "Invalid plugin name: $plugin" >&2
        exit 1
    fi

    echo "$plugin_name $hr_name"
}

PLUGIN_NAME=""
HR_NAME=""
EXT_PLUGIN_NAME=""
EXT_HR_NAME=""
IS_PARENT=false
while getopts ":p:e:t" opt; do
    case $opt in
        p)
            read -r PLUGIN_NAME HR_NAME < <(validate_plugin_name "$OPTARG")
            ;;
        e)
            read -r EXT_PLUGIN_NAME EXT_HR_NAME < <(validate_plugin_name "$OPTARG")
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

QV_PLUGIN_CONFIG_DIR="${QV_PLUGIN_CONFIG_DIR:-"$QUANTUMVIM_DIR"/lua/qvim/core/plugins}"
QV_LAZY_PLUGIN_SPEC_DIR="${QV_LAZY_PLUGIN_SPEC_DIR:-"$QUANTUMVIM_DIR"/lua/qvim/core/loader/spec/config}"

QV_PLUGIN_PARENT_DIR="${QV_PLUGIN_PARENT_DIR:-"$QV_PLUGIN_CONFIG_DIR"/"$HR_NAME"}"

function generate_plugin_config_file() {

    [ ! -d "$QV_PLUGIN_CONFIG_DIR" ] && mkdir -p "$QV_PLUGIN_CONFIG_DIR"

    local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/plugin.lua.template"
    local src_spec="$QUANTUMVIM_DIR/utils/scripts/templates/spec.lua.template"
    local dst_spec="$QV_LAZY_PLUGIN_SPEC_DIR/$HR_NAME.lua"

    local ITERATIONS=2
    if [[ -n "$PLUGIN_NAME"  && -z "$EXT_PLUGIN_NAME" && -n "$EXT_HR_NAME" && "$IS_PARENT" == "false" ]]; then
        mkdir -p "${QV_PLUGIN_PARENT_DIR}"
        # Create an extension in an existing parent
        local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/extension.lua.template"
        local dst_plugin="${QV_PLUGIN_PARENT_DIR}/${EXT_HR_NAME}.lua"
        if [ -f "$dst_spec" ]; then
            ITERATIONS=1
            local sources=("$src_plugin")
            local destinations=("$dst_plugin")
        else
            local sources=("$src_plugin" "$src_spec")
            local destinations=("$dst_plugin" "$dst_spec")
        fi

    elif [[  -n "$PLUGIN_NAME" && "$IS_PARENT" == "true" && -z "$EXT_PLUGIN_NAME" && -n "$EXT_HR_NAME" ]]; then
        # Create a parent folder
        mkdir -p "${QV_PLUGIN_PARENT_DIR}"
        local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/init.lua.template"
        local dst_plugin="${QV_PLUGIN_PARENT_DIR}/init.lua"
        local sources=("$src_plugin" "$src_spec")
        local destinations=("$dst_plugin" "$dst_spec")
    elif [[ -n "$PLUGIN_NAME" && "$IS_PARENT" == "true" && -n "$EXT_PLUGIN_NAME" && -n "$EXT_HR_NAME" ]]; then
        # make parent with extension
        mkdir -p "${QV_PLUGIN_PARENT_DIR}"
        local src_plugin="$QUANTUMVIM_DIR/utils/scripts/templates/init.lua.template"
        local src_ext="$QUANTUMVIM_DIR/utils/scripts/templates/extension.lua.template"
        local dst_plugin="${QV_PLUGIN_PARENT_DIR}/init.lua"
        local dst_ext="${QV_PLUGIN_PARENT_DIR}/${EXT_HR_NAME}.lua"
        local sources=("$src_plugin" "$src_ext" "$src_spec")
        local destinations=("$dst_plugin" "$dst_ext" "$dst_spec")
        ITERATIONS=3
    else
        # Normal plugin
        local dst_plugin="$QV_PLUGIN_CONFIG_DIR/$HR_NAME.lua"
        local sources=("$src_plugin" "$src_spec")
        local destinations=("$dst_plugin" "$dst_spec")
    fi

    for (( i=0; i<ITERATIONS; i++ )); do
        if [ -f "${destinations[i]}" ]; then
            mv "${destinations[i]}" "${destinations[i]}".old
        fi

        cp "${sources[i]}" "${destinations[i]}"

        sed -e s"#QV_STRING_EXT_PLUGIN_NAME_VAR#${EXT_HR_NAME}#"g \
            -e s"#QV_EXT_PLUGIN_VAR#${EXT_PLUGIN_NAME}#"g \
            -e s"#QV_STRING_PLUGIN_NAME_VAR#${HR_NAME}#"g \
            -e s"#QV_PLUGIN_NAME_VAR#${PLUGIN_NAME}#"g "${sources[i]}" \
            | tee "${destinations[i]}" >/dev/null

    done

}

generate_plugin_config_file

echo "Plugin config file generated. Remember to add the plugin to the configuration and to the lazy table."

exit 0
