# Module manager for conditional module loading based on host configuration
{ config, lib, pkgs, ... }:

let
  # Helper function to safely access host configuration
  # This function gracefully handles undefined paths with default values
  getConfigValue = path: default:
    if lib.hasAttrByPath path config
    then lib.getAttrFromPath path config
    else default;

  # Host module preferences with defaults
  # These are fallback values that only apply if no host configuration exists
  hostModules = getConfigValue ["system" "nixos-dotfiles" "host" "modules" "enable"] {
    hyprland = true;
    gnome = false;
    cuda = false;
    localLLM = false;
    printing = false;
    clamav = false;
    macRandomize = false;
    autoUpgrade = false;
  };

  # Host hardware capabilities with defaults
  hostHardware = getConfigValue ["system" "nixos-dotfiles" "host" "hardware"] {
    hasNvidia = false;
    hasBluetooth = false;
    hasFingerprint = false;
  };

  # Safer access functions for specific values
  moduleEnabled = name: getConfigValue ["system" "nixos-dotfiles" "host" "modules" "enable" name]
    (if builtins.hasAttr name hostModules then hostModules.${name} else false);

  hardwareHas = capability: getConfigValue ["system" "nixos-dotfiles" "host" "hardware" capability]
    (if builtins.hasAttr capability hostHardware then hostHardware.${capability} else false);
in {
  # Import modules conditionally based on host configuration
  imports = lib.flatten [
    # System modules - remaining modules that weren't in core-modules.nix
    [
      ./system/gc.nix
      ./system/swap.nix
      ./system/bootloader.nix
      ./system/linux-kernel.nix
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
      ./development/programming-languages.nix
      ./development/lsp.nix
      ./development/wasm.nix
      ./development/terminal-utils.nix
      ./development/info-fetchers.nix
      ./development/utils.nix
      ./development/llm.nix
      ./development/work.nix
      ./development/cad.nix
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

  # This enables CUDA for the entire system if the host has it enabled
  nixpkgs.config = lib.mkIf (moduleEnabled "cuda") {
    cudaSupport = true;
  };
}