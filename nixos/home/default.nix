{inputs, username, host, ...}: {
  imports = [
    ./rofi.nix
    ./fish.nix
    ./hyprland.nix
    ./neovim.nix
    ./ghostty.nix
  ];
}

