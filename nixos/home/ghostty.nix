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
    shell-integration = enabled
    shell-integration-features = sudo,command-status
    
    # Cursor configuration
    cursor-style = block
    cursor-style-blink = true
    
    # Keybindings
    keybind = alt+c=copy_to_clipboard
    keybind = alt+v=paste_from_clipboard
    keybind = alt+shift+t=new_tab
    keybind = alt+shift+q=quit
    keybind = alt+shift+w=close_surface
    keybind = alt+shift+n=new_window
    keybind = alt+shift+f=toggle_fullscreen
    keybind = alt+shift+plus=increase_font_size
    keybind = alt+shift+minus=decrease_font_size
    keybind = alt+shift+0=reset_font_size
    keybind = alt+shift+r=reload_config
    
    # Tab navigation (consistent with Neovim)
    keybind = alt+h=previous_tab
    keybind = alt+l=next_tab
    keybind = alt+1=goto_tab:0
    keybind = alt+2=goto_tab:1
    keybind = alt+3=goto_tab:2
    keybind = alt+4=goto_tab:3
    keybind = alt+5=goto_tab:4
    keybind = alt+6=goto_tab:5
    keybind = alt+7=goto_tab:6
    keybind = alt+8=goto_tab:7
    keybind = alt+9=goto_tab:8
    
    # Spawn a new neovim terminal with Alt+n (consistent with our system)
    keybind = alt+n=spawn:/usr/bin/env nvim
    
    # Tab and window appearance
    window-inherit-working-directory = true
    tab-bar-show-when-one = true
    adjust-cell-width = 0
    adjust-cell-height = 0
    
    # Enable clipboard to primary selection
    clipboard-read = allow
    clipboard-write = allow
    
    # Performance settings
    working-directory = current

    # Exit confirmation
    confirm-close-surface = false
  '';
  
  # Ensure Ghostty is installed
  home.packages = with pkgs; [
    ghostty
  ];
}