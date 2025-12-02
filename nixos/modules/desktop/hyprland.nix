{ inputs, pkgs, config, ... }:

{
  # Enable Hyprland system-wide
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  
  # Set environment variables for Wayland compatibility
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    # Set cursor theme variables system-wide so they're available at login
    HYPRCURSOR_THEME = "Catppuccin-Macchiato-Sapphire-Cursors";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Catppuccin-Macchiato-Sapphire-Cursors";
    XCURSOR_SIZE = "24";
  };

  # Enable Hyprlock and Hypridle system-wide (configuration is in home-manager)
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  # Enable xdg-desktop-portal for screen sharing/window capture (needed for OBS Studio)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # System-wide packages needed for Hyprland
  environment.systemPackages = with pkgs; [
    # Essential terminal applications
    kitty
    cool-retro-term
    ghostty

    # Editing tools
    starship
    helix

    # Graphical applications
    qutebrowser
    zathura
    mpv
    imv
  ];

  # Note: Resource limits for Hyprland cannot be set this way with UWSM.
  # UWSM manages the wayland-wm@Hyprland.service dynamically.
  # If you need resource limits, configure them via:
  # 1. systemd user session limits (/etc/systemd/user.conf)
  # 2. Or create a systemd drop-in file at runtime
}