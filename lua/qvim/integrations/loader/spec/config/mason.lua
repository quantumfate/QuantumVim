local mason = {
    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog"
    },
    build = ":MasonUpdate",
    event = "User FileOpened",
    lazy = true,
}

return mason
