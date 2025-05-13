# Common configuration shared by all hosts
{ lib, config, pkgs, ... }:

{
  # Basic system settings for all hosts
  system.nixos-dotfiles = {
    host = {
      # Default hardware configuration (conservative options)
      hardware = {
        hasBluetooth = false;
        hasNvidia = false;
        hasFingerprint = false;
        hasTouchpad = false;
        hasWebcam = false;
        isBattery = false;
      };
      
      # Default display configuration
      displays = {
        primary = lib.mkDefault "eDP-1"; # Most common primary display name for laptops
        secondary = lib.mkDefault null;
        tertiary = lib.mkDefault null;
        primaryScale = lib.mkDefault 1.0;
        secondaryScale = lib.mkDefault 1.0;
        tertiaryScale = lib.mkDefault 1.0;
        secondaryRotate = lib.mkDefault null;
        tertiaryRotate = lib.mkDefault null;
      };
      
      # Default module enablement
      modules = {
        enable = {
          hyprland = true;
          gnome = false;
          cuda = false;
          localLLM = false;
          printing = false;
          clamav = false;
          macRandomize = false;
          autoUpgrade = false;
        };
      };
      
      # Default Git configuration (empty, will be populated from sops-nix)
      git = {
        user = {
          name = "Default User";
          email = "user@example.com";
          signingKey = null;
        };
        includes = [];
      };
    };
  };
}