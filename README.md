# QuantumVim

![QuantumVim](./images/quantumvim.png)

## Disclaimer

Heavily inspired by [LunarVim](https://github.com/LunarVim/LunarVim)!

## Dependencies

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- zip
- wget

## Features

- automatically setup everything needed for a filetype (dap, lsp, linters, formatting, diagnostics)
- scalable keymap declaration with minimal effort

### Languages

Checkout the [Languages section](./lua/qvim/lang/README.md)

## Testing

Run `make test-local` in the root directory of the project.

## Install

### HTTPS

- currently only on linux and mac

```bash
bash <(curl -s https://raw.githubusercontent.com/quantumfate/quantumvim/main/utils/installer/install.sh)
```

### SSH

```bash
bash <(curl -s https://raw.githubusercontent.com/quantumfate/quantumvim/main/utils/installer/install.sh) --ssh
```

## Run and runtime

Run QuantumVim by `qvim` instead of `nvim`. The runtime/configuration files are located in `~/.config/qvim/`
