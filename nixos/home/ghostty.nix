{pkgs, ...}: {
  # Configure Ghostty terminal
  xdg.configFile."ghostty/config".text = ''
    # Catppuccin Macchiato theme
    background = #24273a
    foreground = #cad3f5
    cursor-color = #f4dbd6
    selection-background = #5b6078
    selection-foreground = #cad3f5
    
    # Normal colors
    palette = 0=#494d64
    palette = 1=#ed8796
    palette = 2=#a6da95
    palette = 3=#eed49f
    palette = 4=#8aadf4
    palette = 5=#f5bde6
    palette = 6=#8bd5ca
    palette = 7=#b8c0e0
    
    # Bright colors
    palette = 8=#5b6078
    palette = 9=#ed8796
    palette = 10=#a6da95
    palette = 11=#eed49f
    palette = 12=#8aadf4
    palette = 13=#f5bde6
    palette = 14=#8bd5ca
    palette = 15=#a5adcb
    
    # Font configuration
    font-family = JetBrains Mono
    font-size = 12
    font-feature = calt
    font-feature = liga
    font-feature = ss01
    font-feature = ss02
    font-feature = ss03
    font-feature = ss04
    font-feature = ss05
    font-feature = ss06
    font-feature = ss07
    font-feature = ss08
    
    # Window configuration
    window-decoration = false
    window-padding-x = 10
    window-padding-y = 10
    window-theme = dark
    macos-non-native-fullscreen = true
    
    # Shell integration
    shell-integration = detect
    
    # Cursor configuration
    cursor-style = block
    cursor-style-blink = true
    
    # Window settings
    window-inherit-working-directory = true
    adjust-cell-width = 0
    adjust-cell-height = 0
    
    # Enable clipboard to primary selection
    clipboard-read = allow
    clipboard-write = allow
    
    # Performance settings
    working-directory = current
    
    # GPU acceleration and rendering optimizations
    gtk-single-instance = true
    window-vsync = false
    
    # Fix input buffering issues
    gtk-adwaita = false
    
    # Reduce input latency
    mouse-hide-while-typing = true

    # Exit confirmation
    confirm-close-surface = false
  '';
  
  # Note: ghostty package is installed system-wide in modules/desktop/hyprland.nix
}