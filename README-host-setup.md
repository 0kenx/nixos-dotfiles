# Host-Specific Configuration for NixOS Dotfiles

This document explains how to set up and customize host-specific configurations within this NixOS dotfiles repository.

## Overview

The configuration is designed to be modular, allowing you to:

1. Use the same dotfiles repository across multiple machines
2. Customize display setups, hardware support, and modules on a per-host basis
3. Manage secrets securely using sops-nix
4. Build and switch to specific host configurations using flake outputs

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/username/nixos-dotfiles.git
cd nixos-dotfiles
```

### 2. Initialize Secrets Submodule (Optional)

If you're using the included secrets management:

```bash
git submodule update --init --recursive
```

### 3. Choose or Create a Host Configuration

#### Using an Existing Host Configuration

The repository includes example configurations for common setups:
- `hosts/laptop/default.nix` - For laptops and portable devices
- `hosts/workstation/default.nix` - For desktops and workstations

#### Creating a New Host Configuration

To create a new host configuration, copy an existing one and modify it:

```bash
mkdir -p nixos/hosts/my-hostname
cp nixos/hosts/laptop/default.nix nixos/hosts/my-hostname/default.nix
```

Then edit `nixos/hosts/my-hostname/default.nix` to match your system.

### 4. Build and Switch to Your Host Configuration

```bash
# From the repository root
sudo nixos-rebuild switch --flake .#my-hostname
```

Where `my-hostname` is one of:
- `laptop` - For the laptop configuration
- `workstation` - For the workstation configuration
- Any custom host you've created

## Host Configuration Structure

Each host configuration file (`hosts/*/default.nix`) defines:

### 1. Basic Host Information

```nix
networking.hostName = "my-hostname";

system.nixos-dotfiles.host = {
  name = "my-hostname";
  # ... other settings
};
```

### 2. Hardware Capabilities

```nix
system.nixos-dotfiles.host.hardware = {
  hasBluetooth = true;
  hasNvidia = false;
  hasFingerprint = true;
  hasTouchpad = true;
  hasWebcam = true;
  isBattery = true;
};
```

### 3. Display Configuration

```nix
system.nixos-dotfiles.host.displays = {
  primary = "eDP-1";                  # Built-in laptop screen
  secondary = "HDMI-A-1";             # External display
  tertiary = null;                    # No third display
  primaryScale = 1.6;                 # HiDPI scaling
  secondaryScale = 1.0;
  tertiaryScale = 1.0;
  secondaryRotate = "left";           # Vertical orientation for secondary
  tertiaryRotate = null;
  secondaryPosition = "0x-1080";      # Explicit position for secondary monitor
  tertiaryPosition = null;
};
```

The display positions can be:
- `auto-right` - Default auto-right placement
- `auto-left` - Default auto-left placement
- `auto-up` - Default auto-up placement
- `auto-down` - Default auto-down placement
- `0x-1080` - Explicit position (x and y coordinates)

For monitors with rotation, the system will calculate the best position automatically if not specified explicitly.

### 4. Module Enablement

```nix
system.nixos-dotfiles.host.modules.enable = {
  hyprland = true;       # Enable Hyprland
  gnome = false;         # Disable GNOME
  cuda = true;           # Enable CUDA
  localLLM = true;       # Enable local LLM support
  printing = true;       # Enable printing
  clamav = false;        # Disable ClamAV
  macRandomize = false;  # Disable MAC randomization
  autoUpgrade = false;   # Disable automatic upgrades
};
```

### 5. Git Configuration

```nix
system.nixos-dotfiles.host.git = {
  user = {
    name = "Your Name";
    email = "your.email@example.com";
    signingKey = "YOUR_GPG_KEY_ID";
  };
  includes = [
    {
      condition = "gitdir:~/projects/";
      contents = {
        user = {
          name = "Your Name";
          email = "your.email@example.com";
        };
      };
    }
    {
      condition = "gitdir:~/work/";
      contents = {
        user = {
          name = "Work Name";
          email = "work.email@company.com";
        };
      };
    }
  ];
};
```

### 6. Host-Specific Packages

```nix
environment.systemPackages = with pkgs; [
  # Add host-specific packages here
  powertop
  tlp
];
```

## How It Works

### Module Management

The system uses conditional module imports based on your host configuration. This is managed in `modules/module-manager.nix`, which:

1. Always loads core modules required for any system
2. Conditionally loads modules based on your host configuration settings
3. Uses the host's hardware capabilities to determine appropriate modules
4. Applies special configurations like CUDA support when enabled

### Display Layout

The display configuration is automatically translated to:

1. Appropriate Hyprland monitor configurations
2. Workspace assignments for each monitor
3. Dynamic monitor positioning scripts that adjust based on rotation settings
4. Wallpaper assignments based on display orientation

The system supports both automatic positioning (auto-right, auto-left, etc.) and explicit positioning (0x-1080) for your displays, so you can create a consistent layout regardless of the actual connector names on different machines.

### Secrets Management

Secrets are managed using sops-nix and stored in the `nixos-secrets` submodule. 
See [README-secrets.md](./README-secrets.md) for details on setting up secrets.

## Tips

### Checking Current Configuration

To see the current host configuration:

```bash
sudo nixos-rebuild dry-build --flake .#hostname
```

### Testing a Different Host Configuration

You can build and test a different host configuration without switching:

```bash
sudo nixos-rebuild test --flake .#other-hostname
```

### Updating All Hosts

To update packages for all hosts:

```bash
nix flake update
```

Then rebuild for your current host:

```bash
sudo nixos-rebuild switch --flake .#hostname
```