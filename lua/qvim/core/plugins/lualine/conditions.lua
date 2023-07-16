local window_width_limit = 100

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
        return vim.o.columns > window_width_limit
    end,
    -- check_git_workspace = function()
    --   local filepath = vim.fn.expand "%:p:h"
    --   local gitdir = vim.fn.finddir(".git", filepath .. ";")
    --   return gitdir and #gitdir > 0 and #gitdir < #filepath
    -- end,
    no_clients = function()
        local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
        return #buf_clients == 0
    end
}

return conditions
