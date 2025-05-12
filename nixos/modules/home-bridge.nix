{config, lib, ...}:

{
  # This module creates a bridge between NixOS system configuration and home-manager
  # It allows home-manager modules to access system-level configuration
  
  config = {
    # Create a special module for home-manager that exposes system configuration
    home-manager.sharedModules = [ 
      # This module will be imported automatically in all home-manager configurations
      {
        # Make system configuration options available to home-manager
        options = {
          systemConfig = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "System configuration options";
          };
        };
        
        # Set the actual system configuration values
        config.systemConfig = {
          # Host-specific information
          host = config.system.nixos-dotfiles.host;
          
          # Hyprland settings
          hyprland = config.system.nixos-dotfiles.hyprland;
          
          # Add other system settings as needed
        };
      }
    ];
  };
}