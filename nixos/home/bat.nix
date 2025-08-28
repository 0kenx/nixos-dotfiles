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
      url = "https://raw.githubusercontent.com/catppuccin/bat/6810349b28055dce54076712fc05fc68da4b8ec0/themes/Catppuccin%20Macchiato.tmTheme";
      sha256 = "sha256-EQCQ9lW5cOVp2C+zeAwWF2m1m6I0wpDQA5wejEm7WgY=";
    };
  };
}