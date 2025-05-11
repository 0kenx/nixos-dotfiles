{config, lib, pkgs, ...}: {
  imports = [
    ../modules/per-host.nix
  ];
  
  # Configuration specific to this host
  system.nixos-dotfiles = {
    host = {
      name = "example-laptop";
    };
    
    hyprland = {
      monitors = [
        "eDP-1,preferred,auto,1.6"
        "HDMI-A-1,preferred,auto-up,1.6"
      ];
    };
  };
  
  # Host-specific configurations other than git can go here
  # Git configuration is now handled through the home-manager module in git.nix
}