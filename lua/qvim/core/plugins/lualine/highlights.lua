---@class lualine_highlights
local lualine_highlights = {
    branch = "%#SLGitIcon#" .. qvim.icons.git.Branch .. "%*" .. "%#SLBranchName#"
}

return lualine_highlights
