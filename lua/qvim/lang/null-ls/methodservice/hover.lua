---@class MethodService
local MethodService = require("qvim.lang.null-ls.methodservice")

---@class Hover : MethodService
local M = MethodService:init(require("null-ls").methods.HOVER)

return M
