function _G.in_headless_mode()
    return #vim.api.nvim_list_uis() == 0
end
