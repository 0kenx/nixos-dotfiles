# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ pkgs, channel, ... }:

{
  # Import essential modules in the correct order:
  # 1. First, the host configuration schema (no actual values yet)
  # 2. Second, core modules that are required for all systems
  # 3. Then, the module manager which conditionally imports other modules
  imports = [
    # Host configuration schema definition (defines the option types)
    ./modules/host-config.nix

    # Core modules that don't depend on host configuration
    ./modules/system/core-modules.nix

    # Module manager for conditional imports based on host configuration
    ./modules/module-manager.nix
  ];

  # Run unpatched dynamic binaries on NixOS.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ glibc gcc.cc.lib ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "${channel}"; # Did you read the comment?
}
