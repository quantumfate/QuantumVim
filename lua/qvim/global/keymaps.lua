local Log = require "qvim.integrations.log"

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
