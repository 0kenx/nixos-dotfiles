{ pkgs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    inconsolata-nerdfont
    jetbrains-mono
    nerd-font-patcher
    noto-fonts-color-emoji
  ];
}
