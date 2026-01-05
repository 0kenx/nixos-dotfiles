# Workstation configuration extending the common configuration
{ lib, config, pkgs, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
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
      hasFingerprint = true; # Synaptics FS7605
      hasTouchpad = false;
      hasWebcam = true;
      isBattery = false; # Desktop computer
    };

    # Display setup for multi-monitor workstation with explicit positioning
    displays = {
      # Use serial numbers for automatic detection
      primarySerial = "VNA6R2XB"; # Main display (Lenovo S28u-10)
      secondarySerial = "VNA6R2XA"; # Secondary display (Lenovo S28u-10)
      tertiarySerial = null;

      # Fallback to port names if serial detection fails
      primary = "HDMI-A-1";
      secondary = "DP-5";
      tertiary = null;

      primaryScale = 1.6;
      secondaryScale = 1.6;
      tertiaryScale = 1.0;
      secondaryRotate = "left"; # Vertical orientation
      tertiaryRotate = null;
      # Explicit secondary monitor position (to the left, bottom aligned with primary)
      # Secondary rotated (1350w x 2400h logical), so x=-1350, y=-1050 for bottom alignment
      secondaryPosition = "-1350x-1050";
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
        autoUpgrade = true; # Automatic flake updates and rebuilds
        wacom = true; # Enable Wacom tablet support
        winboat = true; # Enable WinBoat for Windows apps
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

  # Use data drive for Nix builds (more space than root partition)
  nix.settings.build-dir = "/media/data/nix-build";
  systemd.tmpfiles.rules = [
    "d /media/data/nix-build 1777 root root -"
  ];

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
