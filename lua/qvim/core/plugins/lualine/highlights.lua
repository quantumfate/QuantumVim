---@class lualine_highlights
---@field branch string
---@field ComponentDividerDarkBg fun(string: string):string
---@field ItemInactiveGreyBg fun(string: string):string
local lualine_highlights = {
    branch = "%#QVLLGitIcon#" .. qvim.icons.git.Branch .. "%*" .. "%#QVLLGitIcon#",
    ComponentDividerDarkBg = function(string)
        return "%#QVLLComponentSeparatorGreyBg#" ..
            string .. "%*" .. "%#QVLLComponentSeparatorGreyBg#"
    end,
    ItemActiveGreyBg = function(string)
        return "%#QVLLItemActiveGreyBg#" .. string
    end,
    ItemInactiveGreyBg = function(string)
        return "%#QVLLItemInactiveGreyBg#" .. string
    end,
    TextOneGreyBg = function(string)
        return "%#QVLLTextOneGreyBg#" .. string
    end,
    TextTwoGreyBg = function(string)
        return "%#QVLLTextTwoGreyBg#" .. string
    end,


}

return lualine_highlights
