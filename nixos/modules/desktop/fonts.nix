{ pkgs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.inconsolata
    jetbrains-mono
    nerd-font-patcher
    noto-fonts-color-emoji
  ];
}
