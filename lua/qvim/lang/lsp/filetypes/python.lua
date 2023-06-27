---@class python
---@field setup function
local M = {}

---Setup the pycight server for python
---@return boolean server_started whether the jdtls server started
function M.setup()
    -- setup testing
    require("neotest").setup({
        adapters = {
            require("neotest-python")({
                -- Extra arguments for nvim-dap configuration
                -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
                dap = {
                    justMyCode = false,
                    console = "integratedTerminal",
                },
                args = { "--log-level", "DEBUG", "--quiet" },
                runner = "pytest",
            })
        }
    })

    local keymaps = require("qvim.keymaps")

    keymaps:register(nil,
        {
            {
                binding_group = "C",
                name = "+Python",
                bindings = {
                    ["dm"] = { "<cmd>lua require('neotest').run.run()<cr>", "Test Method" },
                    ["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Test Method DAP" },
                    ["df"] = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" },
                    ["dF"] = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
                        "Test Class DAP" },
                    ["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" },
                    c      = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" }
                },
                options = {
                    prefix = "<leader>",
                },
            },

        }
    )
    return false
end

return M
