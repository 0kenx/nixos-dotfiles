{ pkgs, ... }:

{
  # Systemd services setup
  systemd.packages = with pkgs; [
    auto-cpufreq
  ];

  # Enable Services
  programs.direnv.enable = true;
  services.upower.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;
  services.dbus = {
    enable = true;
    implementation = "broker";
    packages = with pkgs; [
      gnome2.GConf
    ];
  };
  services.mpd.enable = true;
  services.fwupd.enable = true;

  # Auto-cpufreq configuration with error suppression
  services.auto-cpufreq = {
    enable = true;
    settings = {
      # Battery mode settings
      battery = {
        governor = "powersave";
        scaling_min_freq = 800000;
        scaling_max_freq = 3000000;
        turbo = "never";
      };

      # Charger mode settings
      charger = {
        governor = "performance";
        scaling_min_freq = 800000;
        scaling_max_freq = 5700000;
        turbo = "auto";
      };
    };
  };
  # services.gnome.core-shell.enable = true;
  # services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  environment.systemPackages = with pkgs; [
    cryptsetup
    at-spi2-atk
    qt6.qtwayland
    psi-notify
    poweralertd
    playerctl
    psmisc
    grim
    slurp
    imagemagick
    swappy
    ffmpeg_6-full
    wl-screenrec
    wl-clipboard
    wl-clip-persist
    cliphist
    xdg-utils
    wtype
    wlrctl
    waybar
    rofi-wayland
    dunst
    avizo
    wlogout
    gifsicle
  ];
}
