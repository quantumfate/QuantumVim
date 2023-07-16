local log = require("qvim.log")

---@generic T
---@class nvim-dap : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, AbstractExtension> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-dap, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: nvim-dap)|nil overwrite the setup function in core_meta_parent
---@field on_setup_done fun(self: nvim-dap, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_dap = {
    enabled = true,
    name = nil,
    extensions = {
        "jay-babu/mason-nvim-dap.nvim",
        "theHamsta/nvim-dap-virtual-text",
        "rcarriga/nvim-dap-ui",
        "rcarriga/cmp-dap",
        "LiadOz/nvim-dap-repl-highlights"
    },
    conf_extensions = {},
    options = {
        breakpoint = {
            text = qvim.icons.ui.Bug,
            texthl = "DiagnosticSignError",
            linehl = "",
            numhl = "",
        },
        breakpoint_rejected = {
            text = qvim.icons.ui.Bug,
            texthl = "DiagnosticSignError",
            linehl = "",
            numhl = "",
        },
        stopped = {
            text = qvim.icons.ui.BoldArrowRight,
            texthl = "DiagnosticSignWarn",
            linehl = "Visual",
            numhl = "DiagnosticSignWarn",
        },
        log = {
            level = "info",
        },
    },
    keymaps = {
        --[[ {
            binding_group = "d",
            name = "+Dap",
            bindings = {
                ["tc"] = { "<cmd>lua require'telescope'.extensions.dap.commands{}<cr>", "Show commands" },
                ["ts"] = { "<cmd>lua require'telescope'.extensions.dap.configurations{}<cr>", "Show setups" },
                ["tv"] = { "<cmd>lua require'telescope'.extensions.dap.variables{}<cr>", "Show variables" },
                ["tf"] = { "<cmd>lua require'telescope'.extensions.dap.frames{}<cr>", "Show frames" },
                ["tb"] = { "<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<cr>", "Show breakpoints" },
                ["b"] = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle breakpoint" },
                ["B"] = { "<cmd>lua require('dap').set_breakpoint()<cr>", "Set breakpoint" },
                ["R"] = { "<cmd>lua require'dap'.continue()<cr>", "Continue|Run" },
                ["so"] = { "<cmd>lua require'dap'.step_over()<cr>", "Step over" },
                ["si"] = { "<cmd>lua require'dap'.step_into()<cr>", "Step into" },
                ["sr"] = { "<cmd>require('dap').step_out()<cr>", "Step out" },
                ["ro"] = { "<cmd>lua require'dap'.repl.open()<cr>", "Repl open" },
                ["rl"] = { "<cmd>lua require('dap').run_last()<cr>", "Run last" },
                ["<backspace>"] = { "<cmd>lua require('dap').restart()<cr>", "Restart" },
            },
            options = {
                prefix = "<leader>",
            },
        }, ]]
    },
    main = "dap",
    on_setup_start = nil,
    ---@param self nvim-dap
    setup = function(self)
        local nvim_mason_dap = self.conf_extensions["mason_nvim_dap"]
        local mason_ok, mason = pcall(require, nvim_mason_dap.main)
        if not mason_ok then
            log:warn("Failed to setup '%s' for '%s'.", nvim_mason_dap.name, self.name)
        end

        mason.setup(nvim_mason_dap.options)

        local ok, dap = pcall(require, self.main)
        if not ok then
            log:warn("Failed to run setup call for '%s'.", self.name)
            return
        end
        if qvim.config.use_icons then
            vim.fn.sign_define("DapBreakpoint", self.options.breakpoint)
            vim.fn.sign_define("DapBreakpointRejected", self.options.breakpoint_rejected)
            vim.fn.sign_define("DapStopped", self.options.stopped)
        end
        dap.set_log_level(self.options.log.level)
    end,
    on_setup_done = nil,
    url = "https://github.com/mfussenegger/nvim-dap",
}

nvim_dap.__index = nvim_dap

return nvim_dap
