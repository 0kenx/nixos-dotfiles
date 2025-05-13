{config, lib, pkgs, ...}: {
  # Configuration specific to this host
  system.nixos-dotfiles = {
    host = {
      name = "nixos";
    };

    hyprland = {
      monitors = [
        "HDMI-A-1,preferred,auto,1.6"  # Main monitor
        "DP-5,preferred,0x-1080,1.6,transform,1" # Secondary monitor (vertical, left of main, bottom aligned @4k)
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
