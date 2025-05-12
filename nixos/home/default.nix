{inputs, username, host, lib, ...}: {
  # Import modules
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

  # Required for home-manager
  home.username = lib.mkForce username;
  home.homeDirectory = lib.mkForce "/home/${username}";

  # This value determines the Home Manager release that your configuration is compatible with
  # Update this value when you update your home-manager or nixpkgs inputs
  home.stateVersion = "24.11";
}

