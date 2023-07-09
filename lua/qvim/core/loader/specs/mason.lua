local mason = {
    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog",
        "MasonUpdate",
    },
    build = function()
        pcall(function()
            require("mason-registry").refresh()
        end)
    end,
    event = "User FileOpened",
    lazy = true,
}

return mason
