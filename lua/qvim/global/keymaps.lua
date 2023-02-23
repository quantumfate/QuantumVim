_G.keymap_mode_adapters = {
    insert_mode = "i",
    normal_mode = "n",
    visual_mode = "v",
    visual_block_mode = "x",
    command_mode = "c",
    operator_pending_mode = "o",
    term_mode = "t",
}

_G.inverted_keymap_mode_adapters = {
    i = "insert_mode",
    n = "normal_mode",
    v = "visual_mode",
    x = "visual_block_mode",
    c = "command_mode",
    o = "operator_pending_mode",
    t = "term_mode",
}

_G.supported_keymap_options = {
    noremap = true,
    buffer = true,
    nowait = true,
    silent = true,
    script = true,
    expr = true,
    unique = true,
    desc = true,
}

_G.supported_whichkey_options = {
    mode = true,
    prefix = true,
}
---Translates a mode adapter
---@param mode string the short written or long written mode
---@return boolean success success on translation
---@return string? mode the translated mode
function _G.translate_mode_adapter(mode)
    if keymap_mode_adapters[mode] then
        return true, inverted_keymap_mode_adapters[keymap_mode_adapters[mode]]
    elseif inverted_keymap_mode_adapters[mode] then
        return true, keymap_mode_adapters[inverted_keymap_mode_adapters[mode]]
    else
        Log:debug("Failed to translate mode! Unsupported mode: '" .. mode)
        return false
    end
end
