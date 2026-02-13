{ pkgs, lib, config, ... }:

let
  isBattery = config.system.nixos-dotfiles.host.hardware.isBattery;
in
{
  # Systemd services setup (auto-cpufreq only on battery-powered devices)
  systemd.packages = lib.optionals isBattery [ pkgs.auto-cpufreq ];

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

  # Auto-cpufreq for automatic CPU frequency scaling (only on battery-powered devices)
  # Custom settings to properly handle Intel Core Ultra hybrid architecture
  services.auto-cpufreq = {
    enable = isBattery;
    settings = {
      # When plugged in: prioritize performance
      charger = {
        governor = "performance";
        scaling_min_freq = 400000;
        scaling_max_freq = 4800000;
        turbo = "auto";
        energy_performance_preference = "performance";
      };
      # On battery: balanced approach to preserve battery life
      battery = {
        governor = "powersave";
        scaling_min_freq = 400000;
        scaling_max_freq = 3000000;
        turbo = "auto";
        energy_performance_preference = "balance_performance";
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
    rofi
    # dunst is managed by home-manager services.dunst (see home/dunst.nix)
    avizo
    wlogout
    gifsicle
  ];
}
