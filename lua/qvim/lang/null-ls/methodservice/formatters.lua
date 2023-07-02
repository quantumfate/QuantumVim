---@class MethodService
local MethodService = require("qvim.lang.null-ls.methodservice")

---@class Formatters : MethodService
local M = MethodService:init(require("null-ls").methods.FORMATTING)

return M
