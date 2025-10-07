{ pkgs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.inconsolata
    jetbrains-mono
    nerd-font-patcher
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
    source-han-mono
  ];
}
