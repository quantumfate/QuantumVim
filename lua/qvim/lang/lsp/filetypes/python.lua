---@class python
---@field setup function
local M = {}

---Setup the pycight server for python
---@return boolean server_started whether the jdtls server started
function M.setup()
    -- setup testing
    require("neotest").setup {
        adapters = {
            require "neotest-python" {
                -- Extra arguments for nvim-dap configuration
                -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
                dap = {
                    justMyCode = false,
                    console = "integratedTerminal",
                },
                args = { "--log-level", "DEBUG", "--quiet" },
                runner = "pytest",
            },
        },
    }

    --local keymaps = require "qvim.keymaps"

    --[[  keymaps:register {
        {
            binding_group = "C",
            name = "+Python",
            bindings = {
                ["m"] = {
                    rhs = "<cmd>lua require('neotest').run.run()<cr>",
                    desc = "Test Method",
                },
                ["M"] = {
                    rhs = "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
                    desc = "Test Method DAP",
                },
                ["f"] = {
                    rhs = "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>",
                    desc = "Test Class",
                },
                ["F"] = {
                    rhs = "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
                    desc = "Test Class DAP",
                },
                ["S"] = {
                    rhs = "<cmd>lua require('neotest').summary.toggle()<cr>",
                    desc = "Test Summary",
                },
                c = {
                    "<cmd>lua require('swenv.api').pick_venv()<cr>",
                    desc = "Choose Env",
                },
            },
            options = {
                prefix = "<leader>",
            },
        },
    } ]]
    return false
end

return M
