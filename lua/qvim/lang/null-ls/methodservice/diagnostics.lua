---@class MethodService
local MethodService = require "qvim.lang.null-ls.methodservice"

---@class Diagnostics : MethodService
local M = MethodService:init(require("null-ls").methods.DIAGNOSTICS)
local null_ls = require "null-ls"

local alternative_methods = {
    null_ls.methods.DIAGNOSTICS_ON_OPEN,
    null_ls.methods.DIAGNOSTICS_ON_SAVE,
}

function M:list_registered(filetype)
    local registered_sources_from_alt = {}
    for _, method in ipairs(alternative_methods) do
        local sources =
            null_ls.get_sources { filetype = filetype, method = method }
        for _, source in ipairs(sources) do
            if
                self.fn_t.any(source.filetypes, function(ft)
                    return ft == filetype
                end)
            then
                table.insert(registered_sources_from_alt, source.name)
            end
        end
    end

    local registered_sources = MethodService.list_registered(self, filetype)

    return vim.tbl_extend(
        "force",
        registered_sources_from_alt,
        registered_sources
    )
end

return M
