return {
    cmd = {
        "TSInstall",
        "TSUninstall",
        "TSUpdate",
        "TSUpdateSync",
        "TSInstallInfo",
        "TSInstallSync",
        "TSInstallFromGrammar",
    },
    event = "User FileOpened",
    dependencies = {
        "LiadOz/nvim-dap-repl-highlights",
        "HiPhish/nvim-ts-rainbow2",
        "JoosepAlviste/nvim-ts-context-commentstring",
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/playground",
        "drybalka/tree-climber.nvim",
    },
}
