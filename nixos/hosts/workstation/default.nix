# Workstation configuration extending the common configuration
{ lib, config, pkgs, ... }:

{
  imports = [
    ../common/default.nix
  ];

  # Host-specific configuration
  networking.hostName = "workstation";

  # Enable specific features for workstation
  system.nixos-dotfiles.host = {
    name = "workstation";

    # Hardware capabilities
    hardware = {
      hasBluetooth = true;
      hasNvidia = true; # NVIDIA GPU available
      hasFingerprint = false;
      hasTouchpad = false;
      hasWebcam = true;
      isBattery = false; # Desktop computer
    };

    # Display setup for multi-monitor workstation with explicit positioning
    displays = {
      primary = "HDMI-A-1"; # Main display
      secondary = "DP-5"; # Secondary display
      tertiary = null;
      primaryScale = 1.6;
      secondaryScale = 1.6;
      tertiaryScale = 1.0;
      secondaryRotate = "left"; # Vertical orientation
      tertiaryRotate = null;
      # Explicit secondary monitor position (bottom aligned with primary)
      secondaryPosition = "0x-1080"; # Place vertical monitor with bottom aligned
      tertiaryPosition = null;
    };

    # Module enablement for workstation
    modules = {
      enable = {
        hyprland = true;
        gnome = false;
        cuda = true; # Enable CUDA for workstation
        localLLM = true; # Enable local LLM on powerful machine
        printing = true;
        clamav = true; # Enable antivirus
        macRandomize = false; # Not needed for stationary machine
        autoUpgrade = false; # Manual control for workstation
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

  # Additional workstation-specific packages
  environment.systemPackages = with pkgs; [
    # Development tools
    # cuda-tools
    # cudnn
    # tensorrt

    # Professional applications
    # blender
    # davinci-resolve

    # Utilities
    # radeontop # If using AMD GPU
    # nvtop # For NVIDIA monitoring
  ];
}
