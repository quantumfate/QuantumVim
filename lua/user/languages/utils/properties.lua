M = {}

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

M.debuggers = {
  "python",        -- Python
  "codelldb",      -- C/C++/Rust
  "bash",          -- Bash
  "javadbg",       -- Java 
  "javatest",      -- Java Tests
}

M.formatters = {
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
}

M.diagnostics = {
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
}

M.hovers = {
  "dictionary",
  "printenv"
}

return M
