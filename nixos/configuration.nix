# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ channel, ... }:

{
  # Import modules explicitly
  imports = [
    # System modules
    ./modules/system/nix-settings.nix
    ./modules/system/gc.nix
    ./modules/system/time.nix
    ./modules/system/swap.nix
    ./modules/system/bootloader.nix
    # ./modules/system/auto-upgrade.nix
    ./modules/system/linux-kernel.nix
    ./modules/system/environment-variables.nix
    ./modules/system/users.nix
    ./modules/system/internationalisation.nix
    ./modules/system/nixpkgs.nix
    # ./modules/system/core-pkgs.nix
    ./modules/system/services.nix
    # ./modules/system/location.nix

    # Hardware modules
    ./modules/hardware/nvidia.nix
    # ./modules/hardware/disable-nvidia.nix
    ./modules/hardware/opengl.nix
    ./modules/hardware/sound.nix
    ./modules/hardware/usb.nix
    ./modules/hardware/keyboard.nix
    # ./modules/hardware/fingerprint-scanner.nix
    ./modules/hardware/bluetooth.nix
    ./modules/hardware/screen.nix

    # Desktop modules
    ./modules/desktop/hyprland.nix
    ./modules/desktop/display-manager.nix
    # ./modules/desktop/gnome.nix
    ./modules/desktop/theme.nix
    ./modules/desktop/fonts.nix

    # Networking modules
    ./modules/networking/networking.nix
    ./modules/networking/openssh.nix
    ./modules/networking/firewall.nix
    ./modules/networking/dns.nix
    ./modules/networking/vpn.nix
    # ./modules/networking/mac-randomize.nix

    # Development modules
    ./modules/development/programming-languages.nix
    ./modules/development/lsp.nix
    ./modules/development/wasm.nix
    ./modules/development/terminal-utils.nix
    ./modules/development/info-fetchers.nix
    ./modules/development/utils.nix
    ./modules/development/llm.nix
    ./modules/development/work.nix
    ./modules/development/cad.nix

    # Security modules
    ./modules/security/yubikey.nix
    ./modules/security/security-services.nix
    # ./modules/security/clamav-scanner.nix

    # Application modules
    ./modules/applications/multimedia.nix
    # ./modules/applications/printing.nix
    ./modules/applications/virtualisation.nix
    # ./modules/applications/framepack.nix

    # Host-specific modules
    ./modules/per-host.nix
    ./modules/secrets.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "${channel}"; # Did you read the comment?
}