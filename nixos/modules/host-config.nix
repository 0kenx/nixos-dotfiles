{lib, ...}:

with lib;

{
  options.system.nixos-dotfiles.host = {
    # Basic host information
    name = mkOption {
      type = types.str;
      default = "default";
      description = "Host name for this configuration";
    };
    
    # Display configuration
    displays = {
      primary = mkOption {
        type = types.str;
        default = "eDP-1";
        description = "Primary display output name";
      };
      
      secondary = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Secondary display output name";
      };
      
      tertiary = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Tertiary display output name";
      };
      
      # Scale factors for each display
      primaryScale = mkOption {
        type = types.float;
        default = 1.0;
        description = "Scale factor for primary display";
      };
      
      secondaryScale = mkOption {
        type = types.float;
        default = 1.0;
        description = "Scale factor for secondary display";
      };
      
      tertiaryScale = mkOption {
        type = types.float;
        default = 1.0;
        description = "Scale factor for tertiary display";
      };
      
      # Display orientation
      secondaryRotate = mkOption {
        type = types.nullOr (types.enum ["normal" "left" "right" "inverted"]);
        default = null;
        description = "Rotation for secondary display (normal, left, right, inverted)";
      };
      
      tertiaryRotate = mkOption {
        type = types.nullOr (types.enum ["normal" "left" "right" "inverted"]);
        default = null;
        description = "Rotation for tertiary display (normal, left, right, inverted)";
      };
      
      # Display positions (explicit positioning overrides auto-positioning)
      secondaryPosition = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Position for secondary display (e.g., '0x-1080' or 'auto-right')";
      };
      
      tertiaryPosition = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Position for tertiary display (e.g., '3840x0' or 'auto-right')";
      };
    };
    
    # Hardware capabilities
    hardware = {
      hasBluetooth = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this host has Bluetooth hardware";
      };
      
      hasNvidia = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this host has NVIDIA graphics";
      };
      
      hasFingerprint = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this host has a fingerprint reader";
      };
      
      hasTouchpad = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this host has a touchpad";
      };
      
      hasWebcam = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this host has a webcam";
      };
      
      isBattery = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this host runs on battery (laptop/mobile)";
      };
    };
    
    # Module management
    modules = {
      # Enable specific module categories
      enable = {
        # Desktop environments
        hyprland = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Hyprland desktop environment";
        };
        
        gnome = mkOption {
          type = types.bool;
          default = false;
          description = "Enable GNOME desktop environment";
        };
        
        # Development tooling
        cuda = mkOption {
          type = types.bool;
          default = false;
          description = "Enable CUDA development support";
        };
        
        localLLM = mkOption {
          type = types.bool;
          default = false;
          description = "Enable local LLM support";
        };
        
        # Peripherals and hardware support
        printing = mkOption {
          type = types.bool;
          default = false;
          description = "Enable printing support";
        };
        
        wacom = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Wacom tablet support with OpenTabletDriver";
        };
        
        # Security features
        clamav = mkOption {
          type = types.bool;
          default = false;
          description = "Enable ClamAV antivirus";
        };
        
        # Networking
        macRandomize = mkOption {
          type = types.bool;
          default = false;
          description = "Enable MAC address randomization";
        };
        
        # Power management
        autoUpgrade = mkOption {
          type = types.bool;
          default = false;
          description = "Enable automatic system upgrades";
        };
      };
    };
    
    # Git configuration
    git = {
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
  };
}