# Module manager for conditional module loading based on host configuration
{ config, lib, pkgs, resolvedHostDotfilesConfig, ... }:

let
  # Use pre-resolved host configuration directly from specialArgs
  # to avoid circular dependencies with home-manager and other modules

  # Helper functions to access values from the pre-resolved configuration
  moduleEnabled = name: resolvedHostDotfilesConfig.modules.enable.${name} or false;
  hardwareHas = capability: resolvedHostDotfilesConfig.hardware.${capability} or false;
in {
  # Import modules conditionally based on host configuration
  imports = lib.flatten [
    # System modules - remaining modules that weren't in core-modules.nix
    [
      ./system/gc.nix
      ./system/swap.nix
      ./system/bootloader.nix
      ./system/linux-kernel.nix
      ./system/utils.nix
      ./system/terminal-utils.nix
      ./system/info-fetchers.nix
    ]

    # Auto-upgrade is conditionally imported
    (lib.optional (moduleEnabled "autoUpgrade") ./system/auto-upgrade.nix)

    # Hardware modules - additional hardware modules not in core-modules.nix
    [
      ./hardware/usb.nix
      ./hardware/screen.nix
    ]

    # Conditional hardware modules
    (lib.optional (hardwareHas "hasNvidia") ./hardware/nvidia.nix)
    (lib.optional (!(hardwareHas "hasNvidia")) ./hardware/disable-nvidia.nix)
    (lib.optional (hardwareHas "hasBluetooth") ./hardware/bluetooth.nix)
    (lib.optional (hardwareHas "hasFingerprint") ./hardware/fingerprint-scanner.nix)

    # Desktop environment modules - conditionally imported based on host preferences
    (lib.optional (moduleEnabled "hyprland") ./desktop/hyprland.nix)
    (lib.optional (moduleEnabled "gnome") ./desktop/gnome.nix)
    [
      ./desktop/display-manager.nix
      ./desktop/theme.nix
      ./desktop/fonts.nix
    ]

    # Networking modules - additional networking modules not in core-modules.nix
    [
      ./networking/openssh.nix
      ./networking/dns.nix
      ./networking/vpn.nix
    ]

    # Conditional networking modules
    (lib.optional (moduleEnabled "macRandomize") ./networking/mac-randomize.nix)

    # Development modules - base development tools always imported
    [
      ./development/toolchain.nix
      ./development/lsp.nix
      ./development/wasm.nix
      ./development/llm.nix
      ./development/work.nix
      ./development/cad.nix
      ./development/ide.nix
      ./development/devops.nix
      ./development/db.nix
    ]

    # Conditional development modules
    (lib.optional (moduleEnabled "localLLM") ./development/llm-local.nix)

    # Security modules - base security always imported
    [
      ./security/yubikey.nix
      ./security/security-services.nix
    ]

    # Conditional security modules
    (lib.optional (moduleEnabled "clamav") ./security/clamav-scanner.nix)

    # Application modules - base applications always imported
    [
      ./applications/multimedia.nix
      ./applications/virtualisation.nix
    ]

    # Conditional application modules
    (lib.optional (moduleEnabled "printing") ./applications/printing.nix)
  ];

  # CUDA configuration moved to flake.nix
}
