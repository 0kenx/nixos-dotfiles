{lib, ...}:

with lib;

{
  options.system.nixos-dotfiles = {
    # Note: Git configuration now uses SOPS for secure secrets
    # See README-secrets.md for details

    # Host-specific information
    host = {
      name = mkOption {
        type = types.str;
        default = "default";
        description = "Name of this host configuration";
      };
    };
    
    # Hyprland configuration options
    hyprland = {
      monitors = mkOption {
        type = types.listOf types.str;
        default = ["eDP-1,preferred,auto,1"];
        description = "Monitor configurations for this host";
      };
    };
    
    # Other host-specific configurations can be added here
  };
}