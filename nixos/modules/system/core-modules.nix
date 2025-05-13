# Core modules that must be imported before module-manager.nix
# These modules are essential for the system and don't depend on host configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    # Core system modules that don't depend on host configuration
    ./nix-settings.nix
    ./nixpkgs.nix
    ./users.nix
    ./environment-variables.nix
    ./services.nix
    ./time.nix
    ./internationalisation.nix
    
    # Hardware modules that are required for all systems
    ../hardware/opengl.nix
    ../hardware/sound.nix
    ../hardware/keyboard.nix
    
    # Networking modules required for all systems
    ../networking/networking.nix
    ../networking/firewall.nix
    
    # Secret management
    ../secrets.nix
  ];
}