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

  # Memory and resource limits for Hyprland
  # Prevents OOM situations by limiting memory usage per user session
  systemd.user.services."wayland-wm@" = {
    serviceConfig = {
      # Limit memory to 16GB (prevents the 19.7GB+ memory leak issue)
      MemoryMax = "16G";
      MemoryHigh = "14G";  # Start applying pressure at 14GB

      # Limit swap usage
      MemorySwapMax = "4G";

      # CPU and task limits to prevent runaway processes
      CPUQuota = "800%";  # Max 8 cores worth on a 20-core system
      TasksMax = "8192";

      # IO limits to prevent disk thrashing
      IOWeight = "100";
    };
  };
}