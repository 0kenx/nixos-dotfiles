{inputs, username, host, pkgs, lib, ...}:
# IMPORTANT: This file has been disabled to prevent circular dependencies
# Host-specific configurations should be defined in the NixOS host config files
# and accessed via nixosConfig in Home Manager modules when needed

{
  # DO NOT USE THIS FILE - It's kept for reference only
  # This was causing problems by trying to define NixOS options from a Home Manager module

  # Home Manager modules should NOT define NixOS options directly
  # Instead they should use the values passed by extraSpecialArgs or accessed via nixosConfig
}