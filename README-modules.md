# NixOS Modules

This document describes the available modules in this NixOS configuration and how they can be enabled or disabled for specific hosts.

## Module System Overview

The configuration uses a modular approach, where modules can be:

1. **Always enabled** - Core functionality needed for all systems
2. **Conditionally enabled** - Based on host-specific configuration
3. **Explicitly disabled** - Even if normally available for a host type

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
│   ├── llm-local.nix
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
├── host-config.nix   # Host configuration options
├── module-manager.nix# Conditional module loading
└── secrets.nix       # Secret management with sops-nix
```

## Available Modules

### System Modules

These modules configure core system functionality:

| Module | Description | Always Enabled | Can Be Configured |
|--------|-------------|----------------|-------------------|
| nix-settings | Nix package manager configuration | ✅ | ✅ |
| gc | Garbage collection settings | ✅ | ✅ |
| time | System time and timezone settings | ✅ | ✅ |
| swap | Swap configuration | ✅ | ✅ |
| bootloader | System boot configuration | ✅ | ✅ |
| auto-upgrade | Automatic system upgrades | ❌ | ✅ |
| linux-kernel | Kernel configuration | ✅ | ✅ |
| environment-variables | Global environment variables | ✅ | ✅ |
| users | User accounts and permissions | ✅ | ✅ |
| internationalisation | Language and locale settings | ✅ | ✅ |
| nixpkgs | Package configuration | ✅ | ✅ |
| services | Core system services | ✅ | ✅ |

### Hardware Modules

These modules configure hardware support:

| Module | Description | Always Enabled | Can Be Configured |
|--------|-------------|----------------|-------------------|
| nvidia | NVIDIA graphics support | ❌ | ✅ |
| disable-nvidia | Explicitly disable NVIDIA | ❌ | ✅ |
| opengl | OpenGL support | ✅ | ✅ |
| sound | Audio system configuration | ✅ | ✅ |
| usb | USB device support | ✅ | ✅ |
| keyboard | Keyboard configuration | ✅ | ✅ |
| fingerprint-scanner | Fingerprint reader support | ❌ | ✅ |
| bluetooth | Bluetooth support | ❌ | ✅ |
| screen | Display and backlight configuration | ✅ | ✅ |

### Desktop Modules

These modules configure desktop environments:

| Module | Description | Always Enabled | Can Be Configured |
|--------|-------------|----------------|-------------------|
| hyprland | Hyprland window manager | ❌ | ✅ |
| gnome | GNOME desktop environment | ❌ | ✅ |
| display-manager | Login manager configuration | ✅ | ✅ |
| theme | Visual theme configuration | ✅ | ✅ |
| fonts | Font configuration and availability | ✅ | ✅ |

### Networking Modules

These modules configure network functionality:

| Module | Description | Always Enabled | Can Be Configured |
|--------|-------------|----------------|-------------------|
| networking | General networking configuration | ✅ | ✅ |
| openssh | SSH server/client configuration | ✅ | ✅ |
| firewall | System firewall configuration | ✅ | ✅ |
| dns | DNS resolution configuration | ✅ | ✅ |
| vpn | VPN client support | ✅ | ✅ |
| mac-randomize | MAC address randomization | ❌ | ✅ |

### Development Modules

These modules configure development tools:

| Module | Description | Always Enabled | Can Be Configured |
|--------|-------------|----------------|-------------------|
| programming-languages | Programming language support | ✅ | ✅ |
| lsp | Language server protocols | ✅ | ✅ |
| wasm | WebAssembly support | ✅ | ✅ |
| terminal-utils | Terminal utilities | ✅ | ✅ |
| info-fetchers | System information tools | ✅ | ✅ |
| utils | Development utilities | ✅ | ✅ |
| llm | LLM tools and APIs | ✅ | ✅ |
| llm-local | Local LLM support (resource-intensive) | ❌ | ✅ |
| work | Work-specific tools | ✅ | ✅ |
| cad | CAD/3D modeling tools | ✅ | ✅ |

### Security Modules

These modules configure security features:

| Module | Description | Always Enabled | Can Be Configured |
|--------|-------------|----------------|-------------------|
| yubikey | YubiKey support | ✅ | ✅ |
| security-services | Security-related services | ✅ | ✅ |
| clamav-scanner | Antivirus scanner | ❌ | ✅ |

### Application Modules

These modules configure applications:

| Module | Description | Always Enabled | Can Be Configured |
|--------|-------------|----------------|-------------------|
| multimedia | Multimedia applications and codecs | ✅ | ✅ |
| printing | Printer support | ❌ | ✅ |
| virtualisation | Virtualization tools | ✅ | ✅ |
| framepack | Frame packing tools | ❌ | ✅ |

## Enabling/Disabling Modules

Modules are enabled or disabled in your host configuration file (`hosts/*/default.nix`):

```nix
system.nixos-dotfiles.host.modules.enable = {
  # Desktop environments
  hyprland = true;  # Enable Hyprland
  gnome = false;    # Disable GNOME
  
  # Development features
  cuda = true;      # Enable CUDA
  localLLM = true;  # Enable local LLM support
  
  # Peripherals
  printing = true;  # Enable printing support
  
  # Security features
  clamav = false;   # Disable ClamAV
  
  # Networking
  macRandomize = false; # Disable MAC randomization
  
  # System
  autoUpgrade = false;  # Disable automatic upgrades
};
```

## How Module Loading Works

The system uses the `module-manager.nix` file to conditionally load modules based on your host configuration. This allows for a clean, declarative way to enable or disable features without editing multiple files.

The module manager:

1. Always loads core modules required for any system
2. Conditionally loads modules based on your host configuration settings
3. Uses the host's hardware capabilities to determine appropriate modules
4. Applies special configurations like CUDA support when enabled

## Adding New Modules

To add a new optional module:

1. Create your module in the appropriate subdirectory of `modules/`
2. Add an entry in `modules/host-config.nix` for your module option
3. Add conditional loading logic in `modules/module-manager.nix`
4. Update this documentation with your new module