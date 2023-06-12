local mason = {
    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog",
        "MasonUpdate"
    },
    build = ":MasonUpdate",
    event = "User FileOpened",
    lazy = true,
}

return mason
