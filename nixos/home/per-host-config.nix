{inputs, username, host, pkgs, ...}: {
  # This file defines configurations that may differ between hosts
  # Import this file in your host-specific NixOS configuration
  
  # Define a module that can be imported in host-specific configurations
  options.nixosConfig.system.nixos-dotfiles = {
    # Git configuration options
    git = {
      # User information
      user = {
        name = mkOption {
          type = types.str;
          default = "Default User";
          description = "Git username";
        };
        email = mkOption {
          type = types.str;
          default = "user@example.com";
          description = "Git email address";
        };
        signingKey = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "GPG key ID for signing commits";
        };
      };
      
      # Git includes for different directories
      includes = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "List of Git include directives";
        example = [
          {
            condition = "gitdir:~/projects/";
            contents = {
              user = {
                name = "Personal Name";
                email = "personal@example.com";
              };
            };
          }
        ];
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
    
    # Other host-specific configurations...
  };
  
  # Example host-specific configuration (to be moved to the specific host's config)
  config = {
    # Example for a personal laptop
    nixosConfig.system.nixos-dotfiles = {
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
      
      hyprland = {
        monitors = [
          "eDP-1,preferred,auto,1.6"
          "HDMI-A-1,preferred,auto-up,1.6"
        ];
      };
    };
  };
}