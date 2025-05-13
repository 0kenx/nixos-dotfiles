# NixOS Dotfiles Module Structure

This document explains the module structure and import order of this NixOS configuration. Understanding this structure is crucial for maintaining and extending the configuration.

## Module Import Order

The import order has been carefully designed to avoid circular dependencies and infinite recursion:

1. **Hardware Configuration**: First, we load hardware-specific configuration.
2. **Host Configuration Values**: Next, we load the actual values for the host configuration (from hosts/{hostname}/default.nix).
3. **Base Configuration**: Then, we load the base configuration (configuration.nix), which imports:
   - Host configuration schema (modules/host-config.nix)
   - Core modules (modules/system/core-modules.nix)
   - Module manager (modules/module-manager.nix)
4. **Secrets Management**: After the core system is configured, we load the secrets management.
5. **Home Manager**: Finally, we load the Home Manager configuration.

## Key Components

### Host Configuration (modules/host-config.nix)

This module defines the schema for host-specific configuration options, but does not assign any values. It provides:

- Display configuration (primary, secondary, tertiary monitors)
- Hardware capabilities (Bluetooth, NVIDIA, fingerprint, etc.)
- Module enablement (Hyprland, GNOME, CUDA, etc.)
- Git configuration (user.name, user.email, etc.)

### Core Modules (modules/system/core-modules.nix)

These are essential modules that are imported before the module manager and don't depend on host configuration:

- Basic system settings (nix-settings.nix, nixpkgs.nix, users.nix, etc.)
- Basic hardware support (opengl.nix, sound.nix, keyboard.nix)
- Basic networking (networking.nix, firewall.nix)
- Secret management (secrets.nix)

### Module Manager (modules/module-manager.nix)

This module conditionally imports other modules based on the host configuration:

- Uses helper functions to safely access host configuration with fallback values
- Groups modules into categories (system, hardware, desktop, networking, etc.)
- Conditionally imports modules based on host preferences
- Applies system-wide configuration based on host preferences (e.g., enabling CUDA)

### Host-Specific Configuration (hosts/{hostname}/default.nix)

These files provide the actual values for host-specific configuration:

- Extends the common configuration (hosts/common/default.nix)
- Sets hardware capabilities
- Configures display setup
- Enables or disables specific modules
- Sets Git configuration
- Adds host-specific packages

## Dependency Resolution

To avoid infinite recursion and circular dependencies:

1. We separate the host configuration **schema** (modules/host-config.nix) from host configuration **values** (hosts/{hostname}/default.nix).
2. We import essential modules (core-modules.nix) before the module manager.
3. We use safe accessor functions in the module manager to gracefully handle undefined paths.
4. We specify a precise import order in flake.nix.

## Adding New Modules

When adding a new module:

1. If it's a core module that should always be loaded, add it to `core-modules.nix`.
2. If it's conditional based on host configuration:
   - Add the relevant option to `host-config.nix`
   - Add the conditional import to `module-manager.nix`
   - Set the option value in your host-specific configuration

## Adding New Hosts

When adding a new host:

1. Create a new directory under hosts/ with the hostname
2. Create a default.nix file in that directory
3. Import the common configuration and override as needed
4. Add the host to the nixosConfigurations in flake.nix

## Troubleshooting

If you encounter infinite recursion errors:

1. Check for circular dependencies in module imports
2. Ensure values are accessed after they're defined
3. Use safe accessor functions with fallback values
4. Make sure core modules are imported before dependent modules
