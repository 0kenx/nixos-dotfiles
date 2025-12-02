# Language Server Setup for direnv Projects

This document explains how LSPs are configured across your development environments.

## Overview

Neovim is configured to use **direnv-provided LSPs** instead of globally-installed ones. This allows per-project language server versions and configurations.

## Global LSPs (via Mason)

Only language-agnostic LSPs are installed globally in `nixos/home/neovim.nix`:

- `lua_ls` - For Neovim configuration editing
- `jsonls` - JSON files
- `yamlls` - YAML files
- `bashls` - Bash scripts
- `marksman` - Markdown files

## Per-Project LSPs (via direnv)

Language-specific LSPs are provided by each project's `flake.nix`:

### Python Projects (`optimized-pre-config-python`)
```nix
python312Packages.python-lsp-server
python312Packages.pylsp-mypy
python312Packages.python-lsp-ruff
```

### Rust Projects (`optimized-pre-config-rust`)
```nix
rust-analyzer
```

### Solidity Projects (`optimized-pre-config-solidity`)
```nix
nodejs  # Required for Solidity LSP
# Solidity LSP is installed via npm in shellHook
```

The Solidity LSP (`@nomicfoundation/solidity-language-server`) is automatically installed via npm when entering the direnv environment.

## How It Works

1. **direnv-vim plugin** automatically loads the environment when you open a file
2. **Language servers** in your PATH are detected by nvim-lspconfig
3. **No global installation** prevents version conflicts between projects

## Adding New Language Presets

When creating a new language preset, include the appropriate LSP:

1. Add the LSP package to `buildInputs` in `flake.nix`
2. Ensure the LSP binary is in PATH
3. Neovim will automatically detect and use it via direnv

## Common LSP Packages

- **JavaScript/TypeScript**: `nodePackages.typescript-language-server`
- **Go**: `gopls`
- **C/C++**: `clangd`
- **Zig**: `zls`
- **Ruby**: `ruby-lsp` or `solargraph`
- **Java**: `jdt-language-server`
- **HTML/CSS**: `nodePackages.vscode-langservers-extracted`

## Troubleshooting

If LSP doesn't work:

1. Check direnv loaded: `:!echo $PATH` in Neovim should show project paths
2. Verify LSP is in PATH: `:!which rust-analyzer` (or other LSP)
3. Check LSP status: `:LspInfo`
4. Restart Neovim after entering direnv environment

## References

- Neovim config: `nixos/home/neovim.nix`
- Language presets: `user/projects/optimized-pre-config-*/`
