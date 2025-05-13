# Template for NixOS module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.template;
in {
  options.modules.template = {
    enable = mkEnableOption "template module";
    
    # Define module-specific options here
    setting1 = mkOption {
      type = types.str;
      default = "default value";
      description = "Description of setting1";
    };

    setting2 = mkOption {
      type = types.bool;
      default = false;
      description = "Description of setting2";
    };
  };

  config = mkIf cfg.enable {
    # Define configuration that should apply when this module is enabled
    
    # Example: Install packages
    environment.systemPackages = with pkgs; [
      # Add packages here
    ];
    
    # Example: Enable services
    # services.someService.enable = true;
    
    # Example: Set configuration values
    # system.something = "value";
    
    # Example: Add files or configurations
    # environment.etc."path/to/file".text = "content";
  };
}