{ inputs, pkgs, ... }:

{
  # Enable Hyprland system-wide
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  
  # Set environment variables for Wayland compatibility
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  # Enable Hyprlock and Hypridle system-wide (configuration is in home-manager)
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

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
}
