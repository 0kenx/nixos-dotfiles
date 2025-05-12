{inputs, username, host, ...}: {
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
}

