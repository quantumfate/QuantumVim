M = {}

-- Reflect LSP Servers
M.servers = {
  "sumneko_lua",  -- Lua
  "pyright",      -- Python
  "ansiblels",    -- Ansible
  "yamlls",       -- Yaml
  "clangd",        -- C/C++
  "cmake",        -- MAKE
  "bashls",       -- Bash
  "jsonls",       -- Json
  "dockerls",     -- Docker
  "graphql",      -- GraphQL
  "jdtls",        -- Java
  "ltex",          -- Latex
  "r_language_server", -- R 
  "tsserver"        -- Typescript
}

-- Reflect DAP provider
M.debuggers = {
  "python",        -- Python
  "codelldb",      -- C/C++/Rust
  "bash",          -- Bash
  "javadbg",       -- Java 
  "javatest",      -- Java Tests
}

-- Reflects the null-ls builtins
M.builtins = {
  formatters = {
    "stylua",             -- Lua
    "black",              -- Python
    "clang_format",       -- C/C++
    "cmake_format",       -- Cmake
    "codespell",          -- Fixes common spellin mistakes
    "eslint",             -- JavaScript
    "fixjson",            -- Json
    "format_r",           -- R
    "google_java_format", -- Java
    "isort",              -- Sort Python imports
    "latexindent",        -- Latex
    "markdown_toc",       -- Markdown Table of Contents
    "markdownlint",       -- Markdown/CommonMark
    "mdformat",           -- Markdown
    "pg_format",          -- PostgreSQL
    "prettier",           -- Common Languages
    "rustfmt",            -- Rust
    "shellharden",        -- Shell
  },
  diagnostics = {
    "ansiblelint",  -- Ansible
    "clang_check",  -- C and C++
    "eslint",       -- JavaScript
    "xo",           -- Typescript
    "jsonlint",     -- Json
    "luacheck",     -- Lua
    "markdownlint", -- Markdown
    "misspell",     -- Spellchecker
    "pylint",       -- Python
    "textlint",     -- Normal text
    "trail_space",  -- Avoid whitespaces
    "yamllint",     -- Yaml
    "zsh"           -- ZSH
  },
  hovers = {
    "dictionary",
    "printenv"
  }

}
-- Currenntly supported by mason-null-ls
M.supported = {
  "blade_formatter",
  "buildifier",
  "cpplint",
  "clang_format",
  "joker",
  "csharpier",
  "djlint",
  "hadolint",
  "elm_format",
  "erb_lint",
  "gitlint",
  "gofumpt",
  "goimports",
  "goimports_reviser",
  "golangci_lint",
  "golines",
  "revive",
  "staticcheck",
  "haml_lint",
  "rome",
  "xo",
  "eslint_d",
  "prettier",
  "prettierd",
  "curlylint",
  "fixjson",
  "jq",
  "ktlint",
  "luacheck",
  "selene",
  "stylua",
  "alex",
  "markdownlint",
  "write_good",
  "cbfmt",
  "proselint",
  "vale",
  "phpcbf",
  "psalm",
  "buf",
  "protolint",
  "autopep8",
  "black",
  "blue",
  "flake8",
  "isort",
  "mypy",
  "pylint",
  "vulture",
  "yapf",
  "rubocop",
  "standardrb",
  "shellcheck",
  "shellharden",
  "shfmt",
  "solhint",
  "sqlfluff",
  "sql_formatter",
  "taplo",
  "vint",
  "actionlint",
  "yamlfmt",
  "yamllint",
  "cfn_lint",
  "codespell",
  "cspell",
  "editorconfig_checker",
  "misspell",
  "textlint",
}  
return M
