# NixOS Organized Configuration Structure

This directory contains the NixOS configuration files organized into logical categories.

## Directory Structure

```
modules/
├── applications/     # Application-specific configurations
│   ├── multimedia.nix
│   ├── printing.nix
│   └── virtualisation.nix
├── desktop/          # Desktop environment and UI configurations
│   ├── display-manager.nix
│   ├── fonts.nix
│   ├── gnome.nix
│   ├── hyprland.nix
│   └── theme.nix
├── development/      # Development tools and languages
│   ├── cad.nix
│   ├── info-fetchers.nix
│   ├── llm.nix
│   ├── lsp.nix
│   ├── programming-languages.nix
│   ├── terminal-utils.nix
│   ├── utils.nix
│   ├── wasm.nix
│   └── work.nix
├── hardware/         # Hardware support configurations
│   ├── bluetooth.nix
│   ├── fingerprint-scanner.nix
│   ├── keyboard.nix
│   ├── nvidia.nix
│   ├── opengl.nix
│   ├── screen.nix
│   ├── sound.nix
│   └── usb.nix
├── networking/       # Network-related configurations
│   ├── dns.nix
│   ├── firewall.nix
│   ├── mac-randomize.nix
│   ├── networking.nix
│   ├── openssh.nix
│   └── vpn.nix
├── security/         # Security features and services
│   ├── clamav-scanner.nix
│   ├── security-services.nix
│   └── yubikey.nix
├── system/           # Core system configuration
│   ├── auto-upgrade.nix
│   ├── bootloader.nix
│   ├── environment-variables.nix
│   ├── gc.nix
│   ├── internationalisation.nix
│   ├── linux-kernel.nix
│   ├── location.nix
│   ├── nix-settings.nix
│   ├── nixpkgs.nix
│   ├── services.nix
│   ├── swap.nix
│   ├── time.nix
│   └── users.nix
├── per-host.nix      # Host-specific configuration module
└── secrets.nix       # Secret management with sops-nix
```

## Usage

The configuration is organized by functionality, with each file focused on a specific aspect of the system. This organization:

1. Makes it easy to find configuration related to a specific domain
2. Keeps each file small and focused on a single responsibility
3. Allows selective inclusion of features by importing specific files

To enable or disable specific configurations, uncomment or comment their import lines in `configuration.nix`.

## Adding New Files

When adding new configuration files:

1. Place them in the appropriate category directory
2. Import them in configuration.nix
3. Keep files focused on a single responsibility

## Host-Specific Configuration

Host-specific configuration is managed through files in the hosts/ directory, which can override general settings for specific machines. The `per-host.nix` module provides a common interface for host-specific options.