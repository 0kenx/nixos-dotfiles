{ pkgs, lib, config, ... }:

let
  isBattery = config.system.nixos-dotfiles.host.hardware.isBattery;

  # Sets platform profile based on AC status and battery level:
  #   AC plugged in  → performance
  #   Battery ≥ 70%  → balanced
  #   Battery < 70%  → low-power
  platformProfileScript = pkgs.writeShellScript "set-platform-profile" ''
    PROFILE_PATH="/sys/firmware/acpi/platform_profile"
    [ -f "$PROFILE_PATH" ] || exit 0

    AC_ONLINE=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -1)

    if [ "$AC_ONLINE" = "1" ]; then
      echo "performance" > "$PROFILE_PATH"
    else
      BATTERY=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
      if [ -n "$BATTERY" ] && [ "$BATTERY" -lt 70 ]; then
        echo "low-power" > "$PROFILE_PATH"
      else
        echo "balanced" > "$PROFILE_PATH"
      fi
    fi
  '';
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
  # Platform profile: performance on AC, balanced on battery, low-power below 70%
  systemd.services.platform-profile = lib.mkIf isBattery {
    description = "Set CPU platform profile based on power state";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${platformProfileScript}";
    };
  };

  systemd.timers.platform-profile = lib.mkIf isBattery {
    description = "Recheck CPU platform profile every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "1min";
      Unit = "platform-profile.service";
    };
  };

  # Trigger immediately on AC plug/unplug
  services.udev.extraRules = lib.mkIf isBattery ''
    SUBSYSTEM=="power_supply", KERNEL=="AC*", RUN+="${pkgs.systemd}/bin/systemctl --no-block start platform-profile.service"
  '';

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
