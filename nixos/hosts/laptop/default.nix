# Laptop configuration extending the common configuration
{ lib, config, pkgs, ... }:

{
  imports = [
    ../common/default.nix
  ];

  # Host-specific configuration
  networking.hostName = "laptop";

  # Enable specific features for laptop
  system.nixos-dotfiles.host = {
    name = "laptop";

    # Hardware capabilities
    hardware = {
      hasBluetooth = true;
      hasNvidia = false; # Integrated graphics only
      hasFingerprint = true;
      hasTouchpad = true;
      hasWebcam = true;
      isBattery = true;
    };

    # Display setup
    displays = {
      primary = "eDP-1"; # Built-in laptop screen
      secondary = "HDMI-A-1"; # For when connected to external display
      tertiary = null;
      primaryScale = 1.0; # HiDPI scaling for laptop screen
      secondaryScale = 1.6;
      tertiaryScale = 1.6;
      secondaryRotate = null;
      tertiaryRotate = null;
      secondaryPosition = "auto-right"; # Position HDMI display to the right of the built-in display
      tertiaryPosition = null;
    };

    # Module enablement
    modules = {
      enable = {
        hyprland = true;
        gnome = false;
        cuda = false; # No CUDA on laptop for battery life
        localLLM = false; # No resource-intensive LLM
        printing = true; # Enable printing
        clamav = false; # Optional antivirus
        macRandomize = false; # Privacy feature for mobile device
        autoUpgrade = true; # Keep laptop updated
      };
    };

    # Git configuration using secrets from sops-nix
    git = {
      user = {
        name = "0kenx";
        email = "km@nxfi.app";
        signingKey = "73834AA6FB6DD8B0";
      };
      includes = [
        {
          condition = "gitdir:~/projects/";
          contents = {
            user = {
              name = "0kenx";
              email = "km@nxfi.app";
            };
          };
        }
        {
          condition = "gitdir:~/work/";
          contents = {
            user = {
              name = "Ken Miller";
              email = "ken.miller@work.com";
            };
          };
        }
      ];
    };
  };

  # Additional laptop-specific packages
  environment.systemPackages = with pkgs; [
    # powertop and tlp removed - auto-cpufreq handles CPU frequency management
    acpi
    light
    zoom-us
  ];

  # Laptop-specific bootloader configuration for dual-booting with Windows
  boot.loader.grub.extraEntries = ''
    menuentry "Windows" {
      insmod part_gpt
      insmod fat
      insmod chain
      set root='hd0,gpt3'
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';
}
