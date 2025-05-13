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
  
  # Make the host information available to home-manager modules
  nixosConfig.system.nixos-dotfiles.host.name = host;
}