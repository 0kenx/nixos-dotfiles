{inputs, username, host, channel, pkgs, lib, hostDisplayConfig, ...}: {
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin-macchiato";
    };
  };

  # Add catppuccin theme files manually to the proper location
  xdg.configFile."bat/themes/Catppuccin-macchiato.tmTheme" = {
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/bat/ba4d16880d63e656acced2b7d4e034e4a93f74b1/Catppuccin-macchiato.tmTheme";
      sha256 = "sha256-76fS4lq8obgOAYaKSVqBc2wOP+RLUCeTQL69vrUfs3k=";
    };
  };
}