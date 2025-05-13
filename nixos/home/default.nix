{inputs, username, host, channel, ...}: {
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
  ];

  # Basic Home Manager configuration
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "${channel}";
  programs.home-manager.enable = true;

  # IMPORTANT: Removed circular reference to NixOS configuration
  # The 'host' variable is already available to all imported home/ modules
  # from home-manager.extraSpecialArgs in flake.nix
}
