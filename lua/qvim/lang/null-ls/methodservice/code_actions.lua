---@class MethodService
local MethodService = require("qvim.lang.null-ls.methodservice")

---@class CodeActions : MethodService
local M = MethodService:init(require("null-ls").methods.CODE_ACTION)

return M
