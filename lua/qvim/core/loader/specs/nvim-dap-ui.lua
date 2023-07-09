local nvim_dap_ui = {
    lazy = true,
    config = function()
        require("qvim.integrations.dap.ui"):setup()
    end,
}

return nvim_dap_ui
