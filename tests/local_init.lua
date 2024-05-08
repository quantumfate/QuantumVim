local path_sep = vim.loop.os_uname().version:match("Windows") and "\\" or "/"
local base_dir = os.getenv("QUANTUMVIM_RTP_DIR")
local tests_dir = base_dir .. path_sep .. "tests"

vim.opt.rtp:append(base_dir)
vim.opt.rtp:append(tests_dir)

require("qvim.bootstrap"):init()
require("qvim.bootstrap"):setup()

-- NOTE: careful about name collisions
-- see https://github.com/nvim-lualine/lualine.nvim/pull/621
require("tests.qvim.helpers")
