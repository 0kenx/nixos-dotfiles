{pkgs, ...}: {
  # GTK Configuration
  gtk = {
    enable = true;
    
    theme = {
      name = "Catppuccin-Macchiato-Standard-Teal-dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "teal" ];
        variant = "macchiato";
      };
    };
    
    iconTheme = {
      name = "Colloid-teal-dark";
      package = pkgs.colloid-icon-theme.override {
        colorVariants = [ "teal" ];
      };
    };
    
    cursorTheme = {
      name = "Catppuccin-Macchiato-Teal-Cursors";
      package = pkgs.catppuccin-cursors.macchiatoTeal;
      size = 24;
    };
    
    font = {
      name = "JetBrains Mono";
      size = 11;
      package = pkgs.jetbrains-mono;
    };
    
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = false;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "none";
        gtk-xft-dpi = 98304;
        gtk-overlay-scrolling = true;
        gtk-key-theme-name = "Default";
        gtk-menu-images = false;
        gtk-button-images = false;
      };
      
      extraCss = ''
        /* Feel free to edit this and see instantaneous results */
      '';
    };
    
    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = false;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "none";
        gtk-xft-dpi = 98304;
        gtk-overlay-scrolling = true;
      };
      
      extraCss = ''
        /* Feel free to edit this and see instantaneous results */
      '';
    };
  };
  
  # Qt theme to match GTK
  qt = {
    enable = true;
    platformTheme = "gtk"; # Keep the old format for home-manager setting
    style = {
      name = "kvantum";
      package = pkgs.libsForQt5.qtstyleplugin-kvantum;
    };
  };
  
  # Configure Kvantum for Qt applications
  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];
  
  xdg.configFile = {
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Catppuccin-Macchiato-Teal
    '';
    
    # Link the Catppuccin-Macchiato-Teal theme for Kvantum
    "Kvantum/Catppuccin-Macchiato-Teal" = {
      source = "${pkgs.catppuccin-kvantum.override {
        accent = "teal";
        variant = "macchiato";
      }}/share/Kvantum/Catppuccin-Macchiato-Teal";
      recursive = true;
    };
  };
}