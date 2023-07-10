# QuantumVim

![QuantumVim](./images/quantumvim.png)

## Disclaimer

This configuration is heavily inspired by [LunarVim](https://github.com/LunarVim/LunarVim).

## Dependencies

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- zip
- wget

## Features

- automatically setup everything needed for a filetype (dap, lsp, linters, formatting, diagnostics)
- scalable keymap declaration with minimal effort

### Languages

Checkout the [Languages section](./lua/qvim/lang/README.md)

## Install

### HTTPS

- currently only on linux and mac

```bash
bash <(curl -s https://raw.githubusercontent.com/quantumfate/quantumvim/main/utils/installer/install.sh)
```

### SSH

## Run and runtime

Run QuantumVim by `qvim` instead of `nvim`. The runtime/configuration files are located in `~/.config/qvim/`
