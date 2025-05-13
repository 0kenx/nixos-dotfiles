{config, lib, pkgs, ...}: {
  # Host-specific configuration
  system.nixos-dotfiles = {
    host = {
      name = "nixos";
    };

    hyprland = {
      monitors = [
        "eDP-1,preferred,auto,1"
        "HDMI-A-1,preferred,auto-up,1.6"
      ];
    };
  };

  # Host-specific configurations
  networking.hostName = "nixos";

  # Hyprland configuration
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Hardware-specific configurations
  hardware.bluetooth.enable = true;

  # Additional packages for this host
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
  ];
}
