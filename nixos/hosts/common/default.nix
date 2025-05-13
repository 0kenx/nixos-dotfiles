# Common configuration shared by all hosts
{ lib, config, pkgs, ... }:

{
  # Basic system settings for all hosts
  system.nixos-dotfiles = {
    host = {
      # Default hardware configuration (conservative options)
      hardware = {
        hasBluetooth = lib.mkDefault false;
        hasNvidia = lib.mkDefault false;
        hasFingerprint = lib.mkDefault false;
        hasTouchpad = lib.mkDefault false;
        hasWebcam = lib.mkDefault false;
        isBattery = lib.mkDefault false;
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
          hyprland = lib.mkDefault true;
          gnome = lib.mkDefault false;
          cuda = lib.mkDefault false;
          localLLM = lib.mkDefault false;
          printing = lib.mkDefault false;
          clamav = lib.mkDefault false;
          macRandomize = lib.mkDefault false;
          autoUpgrade = lib.mkDefault false;
        };
      };
      
      # Default Git configuration (empty, will be populated from sops-nix)
      git = {
        user = {
          name = lib.mkDefault "Default User";
          email = lib.mkDefault "user@example.com";
          signingKey = lib.mkDefault null;
        };
        includes = lib.mkDefault [];
      };
    };
  };
}