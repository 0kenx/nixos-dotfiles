{lib, ...}:

with lib;

{
  options.system.nixos-dotfiles = {
    # Host-specific information
    host = {
      name = mkOption {
        type = types.str;
        default = "default";
        description = "Name of this host configuration";
      };
    };

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
  };
}