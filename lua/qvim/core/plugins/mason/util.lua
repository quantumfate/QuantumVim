---@class mason_util
local mason_util = {}

function mason_util.get_prefix()
    local default_prefix = join_paths(vim.fn.stdpath("data"), "mason")
    return vim.tbl_get(qvim.plugins, "mason", "options", "install_root_dir") or default_prefix
end

---@param append boolean|nil whether to append to prepend to PATH
function mason_util.add_to_path(append)
    local p = join_paths(mason_util.get_prefix(), "bin")
    if vim.env.PATH:match(p) then
        return
    end
    local string_separator = vim.loop.os_uname().version:match("Windows") and ";" or ":"
    if append then
        vim.env.PATH = vim.env.PATH .. string_separator .. p
    else
        vim.env.PATH = p .. string_separator .. vim.env.PATH
    end
end

function mason_util.bootstrap()
    mason_util.add_to_path()
end

return mason_util
