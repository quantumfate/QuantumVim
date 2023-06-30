# Languages

Everything is done by [filetype plugins](https://neovim.io/doc/user/filetype.html). An autocommand will
generate a filetype plugin upon the event `User FileOpened` is triggered with the following content:

- in this example the filetype plugin will tell neovim to setup `lsp`, `null-ls` and `dap` for java

```lua
require("qvim.lang.lsp.manager").setup("jdtls","java")
require("qvim.lang.null-ls.manager").setup("java","jdtls")
require("qvim.lang.dap.manager").setup("java")
```

The filetype plugins will be generated for all supported filetypes and only the necessary dependencies needed for
a filetype will be installed. Everything that is available will be installed by mason.

## LSP

Will install the corresponding language server to a filetype - `jdtls` for java.

## Null-ls

Uses an algorithm to automatically install and register null-ls sources for a filetype.

## Dap

Automatically installs and configures a debug adaper for a filetype.

# Supported Languages and features

The following setup will work out of the box and everything will be installed automatically only with a few exceptions.

- [x] Java
    - [x] LSP: JDTLS setup (Note: You have to provide runtime configuration yourself such as JDK and MavenSettings)
    - [x] DAP: is done through JDTLS in LSP
    - [x] Null-ls: only formatting, rest is done through JDTLS
- [x] Python
    - [x] LSP
    - [x] DAP
    - [x] Null-ls
- [x] C/CPP
    - [x] LSP
    - [x] DAP
    - [x] Null-ls
- [ ] Lua (Specifically designed to work for neovim development)
    - [x] LSP
    - [ ] DAP
    - [x] Null-ls
- [x] Yaml for Ansible
- [x] Json
# Configuration

Here I will discuss the Configuration options in detail.

## Custom packages

Some packages (e.g. Language server, linters, debug adapers, ...) are not available through mason.
Therefor each sub directory provides a `packages` directory such as `null-ls/packages`, `lsp/packages` and `dap/packages`.
Creating a file `<filetype>.lua` such as `java.lua` is supposed to return a table with a valid [mason package spec](https://github.com/williamboman/mason.nvim/blob/main/doc/reference.md).
The provided mason package spec will then be installed. These custom package specs also have precedence over supported mason packages.


## LSP and DAP Filetype extensions

Creating a file called `<filetype>.lua` in `dap|lsp/filetypes` in a setup function will hook advanced logic into the setup.
A boolean value will be returned here to determine whether the configuration for the respective section for a given filetype
is completed. In some cases (like java) it will require you to handle everything yourself through configuration


## LSP providers

Creating a file `<luanguage_server>.lua` in `lsp/providers` will inject settings into the launch of `<luanguage_server>`.

- example for `jsonls.lua`

```lua
local opts = {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
		},
	},
	setup = {
		commands = {
			Format = {
				function()
					vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
				end,
			},
		},
	},
}

return opts
```

## LSP selection

Creating a file such as `<filetype>.lua` in `lsp/selection` will tell lsp which language server to use for a given filetype.
(Note: this is relevant for the template generation and the values defined here are usede befor any filetype is executed)

- example for `java.lua`

```lua
return "jdtls"
```

## Null-ls Filetype extensions

Creating a file called `<filetype>.lua` in `null-ls/filetypes` that returns a table allows to preselect sources for null-ls methods that the algorithm will not overwrite.

- example for `python.lua`

```lua
return {
	formatting = "black",
	diagnostics = "flake8",
}

```

## Null-ls sources options

Creating a file like `<source>.lua` in `null-ls/sources` will inject source specific options.

- example for `flake8.lua`

```lua
return { command = "flake8", filetypes = { "python" } }
```

