---@class lualine_highlights
--- @field branch string
--- @field ComponentSeparatorGreyBg fun(string: string):string
--- @field ComponentSeparatorGreyFgLighterGreyBg fun(string: string):string
--- @field ItemActiveGreyBg fun(string: string):string
--- @field ItemInactiveGreyBg fun(string: string):string
--- @field TextOneGreyBg fun(string: string):string
--- @field TextTwoGreyBg fun(string: string):string
--- @field TextThreeGreyBg fun(string: string):string
--- @field TextFourGreyBg fun(string: string):string
--- @field TextFiveGreyBg fun(string: string):string
--- @field ComponentSeparatorGreyLighterBg fun(string: string):string
--- @field ComponentSeparatorGreyLighterFgGreyBg fun(string: string):string
--- @field ItemActiveGreyLighterBg fun(string: string):string
--- @field ItemInactiveGreyLighterBg fun(string: string):string
--- @field TextOneGreyLighterBg fun(string: string):string
--- @field TextTwoGreyLighterBg fun(string: string):string
--- @field TextThreeGreyLighterBg fun(string: string):string
--- @field TextFourGreyLighterBg fun(string: string):string
--- @field TextFiveGreyLighterBg fun(string: string):string
local lualine_highlights = {
    branch = "%#QVLLGitIcon#" .. qvim.icons.git.Branch .. "%*" .. "%#QVLLGitIcon#",
    ComponentSeparatorGreyBg = function(string)
        return "%#QVLLComponentSeparatorGreyBg#" .. string
    end,
    ComponentSeparatorGreyFgLighterGreyBg = function(string)
        return "%#QVLLComponentSeparatorGreyFgLighterGreyBg#" .. string
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
    TextThreeGreyBg = function(string)
        return "%#QVLLTextThreeGreyBg#" .. string
    end,
    TextFourGreyBg = function(string)
        return "%#QVLLTextFourGreyBg#" .. string
    end,
    TextFiveGreyBg = function(string)
        return "%#QVLLTextFiveGreyBg#" .. string
    end,
    ComponentSeparatorGreyLighterBg = function(string)
        return "%#QVLLComponentSeparatorGreyLighterBg#" .. string
    end,
    ComponentSeparatorGreyLighterFgGreyBg = function(string)
        return "%#QVLLComponentSeparatorGreyLighterFgGreyBg#" .. string
    end,
    ItemActiveGreyLighterBg = function(string)
        return "%#QVLLItemActiveGreyLighterBg#" .. string
    end,
    ItemInactiveGreyLighterBg = function(string)
        return "%#QVLLItemInactiveGreyLighterBg#" .. string
    end,
    TextOneGreyLighterBg = function(string)
        return "%#QVLLTextOneGreyLighterBg#" .. string
    end,
    TextTwoGreyLighterBg = function(string)
        return "%#QVLLTextTwoGreyLighterBg#" .. string
    end,
    TextThreeGreyLighterBg = function(string)
        return "%#QVLLTextThreeGreyLighterBg#" .. string
    end,
    TextFourGreyLighterBg = function(string)
        return "%#QVLLTextFourGreyLighterBg#" .. string
    end,
    TextFiveGreyLighterBg = function(string)
        return "%#QVLLTextFiveGreyLighterBg#" .. string
    end,


}

return lualine_highlights
