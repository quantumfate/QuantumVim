local cmp = {
    event = { "InsertEnter", "CmdlineEnter", "User FileOpened" },
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp" },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-cmdline" },
    },
}

return cmp
