{lib, ...}:

with lib;

{
  options.nixosConfig.system.nixos-dotfiles = {
    # Note: Git configuration now uses SOPS for secure secrets
    # See README-secrets.md for details
    
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