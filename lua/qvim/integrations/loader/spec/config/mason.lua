local mason = {
    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog"
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
