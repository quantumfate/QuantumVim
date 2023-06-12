local luasnip = {
    config = function()
        local utils = require "qvim.utils"
        local paths = {}
        if qvim.luasnip.sources.friendly_snippets then
            paths[#paths + 1] = utils.join_paths(get_qvim_dir(), "site", "pack", "lazy", "opt", "friendly-snippets")
        end
        local user_snippets = utils.join_paths(get_qvim_dir(), "lua", "qvim", "lsp", "snippets")
        if utils.is_directory(user_snippets) then
            paths[#paths + 1] = user_snippets
        end
        require("luasnip.loaders.from_lua").lazy_load()
        require("luasnip.loaders.from_vscode").lazy_load {
            paths = paths,
        }
        require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
}

return luasnip
