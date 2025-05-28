{inputs, username, host, channel, pkgs, lib, hostDisplayConfig, ...}: {
  imports = [
    ./rofi.nix
    ./fish.nix
    ./hyprland.nix
    ./neovim.nix
    ./ghostty.nix
    ./dunst.nix
    ./waybar.nix
    ./git.nix
    ./gtk.nix
    ./ssh.nix
    ./helix.nix
    ./zathura.nix
    ./bat.nix
    ./mpv.nix
    ./kitty.nix
    ./starship.nix
    ./zellij.nix
    ./delta.nix
    ./bottom.nix
    ./tealdeer.nix
    ./neofetch.nix
    ./aiterm.nix

    # GUI Tools
    ./qutebrowser.nix
    ./swappy.nix
    ./thunar.nix
    ./wlogout.nix
    ./xfce4.nix
  ];

  # We're now explicitly starting components with exec-once in Hyprland
  # No need for custom systemd targets

  # Basic Home Manager configuration
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "${channel}";
  programs.home-manager.enable = true;

  # Set cursor theme environment variables globally
  home.sessionVariables = {
    XCURSOR_THEME = "Catppuccin-Macchiato-Sapphire-Cursors";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Catppuccin-Macchiato-Sapphire-Cursors";
    HYPRCURSOR_SIZE = "24";
  };

  # IMPORTANT: Removed circular reference to NixOS configuration
  # The 'host' variable is already available to all imported home/ modules
  # from home-manager.extraSpecialArgs in flake.nix
}
