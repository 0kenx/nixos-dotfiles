{inputs, pkgs, config, lib, nixosConfig, hostDisplayConfig, username, host, channel, ...}:

let
  # Use pre-resolved display configuration directly
  # This avoids circular dependencies with module-manager.nix
  primaryDisplayOutput = hostDisplayConfig.primary or "eDP-1";
  secondaryDisplayOutput = hostDisplayConfig.secondary or null;
  tertiaryDisplayOutput = hostDisplayConfig.tertiary or null;

  primaryScaleFactor = toString (hostDisplayConfig.primaryScale or 1.0);
  secondaryScaleFactor = toString (hostDisplayConfig.secondaryScale or 1.0);
  tertiaryScaleFactor = toString (hostDisplayConfig.tertiaryScale or 1.0);

  getRotateValue = rotation:
    if rotation == "left" then "1"
    else if rotation == "right" then "3"
    else if rotation == "inverted" then "2"
    else "0"; # normal rotation

  secondaryRotationSetting = hostDisplayConfig.secondaryRotate or null;
  tertiaryRotationSetting = hostDisplayConfig.tertiaryRotate or null;

  secondaryTransformValue = if secondaryRotationSetting != null
    then ",transform,${getRotateValue secondaryRotationSetting}"
    else "";

  tertiaryTransformValue = if tertiaryRotationSetting != null
    then ",transform,${getRotateValue tertiaryRotationSetting}"
    else "";

  secondaryPositionValue = hostDisplayConfig.secondaryPosition or "auto-right";
  tertiaryPositionValue = hostDisplayConfig.tertiaryPosition or "auto-right";

  primaryMonitorLine = "${primaryDisplayOutput},preferred,auto,${primaryScaleFactor}";
  secondaryMonitorLine = if secondaryDisplayOutput != null
    then "${secondaryDisplayOutput},preferred,${secondaryPositionValue},${secondaryScaleFactor}${secondaryTransformValue}"
    else "";
  tertiaryMonitorLine = if tertiaryDisplayOutput != null
    then "${tertiaryDisplayOutput},preferred,${tertiaryPositionValue},${tertiaryScaleFactor}${tertiaryTransformValue}"
    else "";

  monitors = lib.filter (m: m != "") [
    primaryMonitorLine
    secondaryMonitorLine
    tertiaryMonitorLine
  ];

  workspaces =
    (map (i: "${toString i},monitor:${primaryDisplayOutput}") (lib.range 1 10)) ++
    (if secondaryDisplayOutput != null then
      (map (i: "${toString i},monitor:${secondaryDisplayOutput}") (lib.range 11 20))
    else []) ++
    (if tertiaryDisplayOutput != null then
      (map (i: "${toString i},monitor:${tertiaryDisplayOutput}") (lib.range 21 30))
    else []);

  # Create a separate monitor setup script instead of embedding bash in the config
  monitorSetupScript = pkgs.writeShellScript "hyprland-monitor-setup" ''
    #!/usr/bin/env bash
    # Detect monitors and configure them appropriately
    if hyprctl monitors -j | jq -e '. | length > 0' > /dev/null; then
      # Primary monitor is always set up first
      hyprctl keyword monitor "${primaryMonitorLine}"

      # If we have secondary monitor and it's detected
      ${if secondaryDisplayOutput != null then ''
      if hyprctl monitors -j | jq -e '. | length > 1' > /dev/null; then
        ${if secondaryPositionValue != "auto-right" then ''
        # Use predefined position
        hyprctl keyword monitor "${secondaryMonitorLine}"
        '' else ''
        # Calculate position based on primary monitor
        PWIDTH=$(hyprctl monitors -j | jq -r '.[] | select(.name=="'"${primaryDisplayOutput}"'") | .width')
        hyprctl keyword monitor "${secondaryDisplayOutput},preferred,$PWIDTH\x0,${secondaryScaleFactor}${secondaryTransformValue}"
        ''}
      fi
      '' else ""}

      # If we have tertiary monitor and it's detected
      ${if tertiaryDisplayOutput != null then ''
      if hyprctl monitors -j | jq -e '. | length > 2' > /dev/null; then
        hyprctl keyword monitor "${tertiaryMonitorLine}"
      fi
      '' else ""}
    fi
  '';
in {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    # Use the same settings as the system configuration
    package = pkgs.hyprland;

    settings = {
      # Monitor configuration from host-specific settings
      # Use exec-once to set up monitors programmatically
      exec-once = [
        # Import environment variables for systemd
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        # Set up monitors first
        "${monitorSetupScript}"
        # Start Hyprland components explicitly (no systemd)
        "hyprpaper"
        "waybar"
        "pypr"
        # Start automounter
        "udiskie --automount --notify --tray"
        # Clipboard history and utilities
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "wl-clip-persist --clipboard regular"
        "avizo-service"
        "systemctl --user start psi-notify"
      ];

      # Fallback static configuration in case the script fails
      monitor = monitors;

      # Workspace assignment based on host configuration
      workspace = workspaces;

      # Define variables for Catppuccin Macchiato colors
      "$rosewater" = "rgb(f4dbd6)";
      "$rosewaterAlpha" = "f4dbd6";
      "$flamingo" = "rgb(f0c6c6)";
      "$flamingoAlpha" = "f0c6c6";
      "$pink" = "rgb(f5bde6)";
      "$pinkAlpha" = "f5bde6";
      "$mauve" = "rgb(c6a0f6)";
      "$mauveAlpha" = "c6a0f6";
      "$red" = "rgb(ed8796)";
      "$redAlpha" = "ed8796";
      "$maroon" = "rgb(ee99a0)";
      "$maroonAlpha" = "ee99a0";
      "$peach" = "rgb(f5a97f)";
      "$peachAlpha" = "f5a97f";
      "$yellow" = "rgb(eed49f)";
      "$yellowAlpha" = "eed49f";
      "$green" = "rgb(a6da95)";
      "$greenAlpha" = "a6da95";
      "$teal" = "rgb(8bd5ca)";
      "$tealAlpha" = "8bd5ca";
      "$sky" = "rgb(91d7e3)";
      "$skyAlpha" = "91d7e3";
      "$sapphire" = "rgb(7dc4e4)";
      "$sapphireAlpha" = "7dc4e4";
      "$blue" = "rgb(8aadf4)";
      "$blueAlpha" = "8aadf4";
      "$lavender" = "rgb(b7bdf8)";
      "$lavenderAlpha" = "b7bdf8";
      "$text" = "rgb(cad3f5)";
      "$textAlpha" = "cad3f5";
      "$subtext1" = "rgb(b8c0e0)";
      "$subtext1Alpha" = "b8c0e0";
      "$subtext0" = "rgb(a5adcb)";
      "$subtext0Alpha" = "a5adcb";
      "$overlay2" = "rgb(939ab7)";
      "$overlay2Alpha" = "939ab7";
      "$overlay1" = "rgb(8087a2)";
      "$overlay1Alpha" = "8087a2";
      "$overlay0" = "rgb(6e738d)";
      "$overlay0Alpha" = "6e738d";
      "$surface2" = "rgb(5b6078)";
      "$surface2Alpha" = "5b6078";
      "$surface1" = "rgb(494d64)";
      "$surface1Alpha" = "494d64";
      "$surface0" = "rgb(363a4f)";
      "$surface0Alpha" = "363a4f";
      "$base" = "rgb(24273a)";
      "$baseAlpha" = "24273a";
      "$mantle" = "rgb(1e2030)";
      "$mantleAlpha" = "1e2030";
      "$crust" = "rgb(181926)";
      "$crustAlpha" = "181926";

      # Input configuration
      input = {
        kb_layout = "us";
        kb_options = "grp:win_space_toggle";
        follow_mouse = 2;
        touchpad = {
          natural_scroll = true;
          tap-and-drag = true;
        };
        sensitivity = 0;
      };

      # XWayland scaling
      xwayland = {
        force_zero_scaling = true;
      };

      # Environment variables
      env = [
        "GDK_SCALE,1.6"
        "HYPRCURSOR_THEME,Catppuccin-Macchiato-Sapphire"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Catppuccin-Macchiato-Sapphire"
        "XCURSOR_SIZE,24"
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "$sapphire";
        "col.inactive_border" = "$surface1";
        layout = "dwindle";
      };

      # Decoration settings
      decoration = {
        rounding = 10;
        blur = {
          size = 8;
          passes = 2;
        };
        shadow = {
          enabled = true;
          range = 15;
          render_power = 3;
          offset = "0, 0";
          color = "$sapphire";
          color_inactive = "0xff$baseAlpha";
        };
        active_opacity = 0.8;
        inactive_opacity = 0.8;
        fullscreen_opacity = 0.8;
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 2, myBezier"
          "windowsOut, 1, 2, default, popin 80%"
          "border, 1, 3, default"
          "fade, 1, 2, default"
          "workspaces, 1, 1, default"
        ];
      };

      # Dwindle layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = true;
        default_split_ratio = 1.2;
        split_bias = 0;
      };

      # Master layout settings
      master = {
        new_status = "master";
      };

      # Gesture settings
      gestures = {
        workspace_swipe = true;
      };

      # Misc settings
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "0x24273a";
      };

      # Binds settings
      binds = {
        workspace_back_and_forth = false;
        workspace_center_on = 1;
      };

      # Device settings
      device = [
        {
          name = "epic mouse V1";
          sensitivity = -0.5;
        }
      ];

      # Cursor settings
      cursor = {
        default_monitor = ["eDP-1" "HDMI-A-1"];
      };

      # Window rules
      windowrule = [
        "float, title:.*mpv$"
        "opaque, title:.*mpv$"
        "size 50% 50%, title:.*mpv$"
        "float, content:video"
        "opaque, content:video"
        "size 50% 50%, content:video"
        "float, title:.*imv.*"
        "opaque, title:.*imv.*"
        "size 70% 70%, title:.*imv.*"
        "float, content:photo"
        "opaque, content:photo"
        "size 70% 70%, content:photo"
        "float, title:.*\\.pdf$"
        "opaque, title:.*\\.pdf$"
        "maximize, title:.*\\.pdf$"
        "opaque, title:.*YouTube - Brave$"
        "opaque, title:swappy"
        "center 1, title:swappy"
        "stayfocused, title:swappy"
        "opaque, title:^TelegramDesktop$"
        "float, $dropterm"
        "float, $volume_sidemenu"
        "opaque, title:^GNU Image Manipulation Program"
        "opaque, class:^gimp$"
        "opaque, class:^Gimp"
        "opaque, title:.*GIMP$"
        "opacity 1.0 override 1.0 override, title:^GNU Image Manipulation Program"
        "opacity 1.0 override 1.0 override, class:^gimp$"
        "opacity 1.0 override 1.0 override, class:^Gimp"
        "opacity 1.0 override 1.0 override, title:.*GIMP$"
        "float, title:iwgtk"
        "float, title:overskride"
        "float, class:Claude"
      ];

      # Variable for mod key
      "$mainMod" = "SUPER";

      # Scratchpad variables
      "$dropterm" = "title:^wezterm_dropdown$";
      "$volume_sidemenu" = "title:^Volume Control$";

      # All keybindings
      bind = [
        # Submaps
        "$mainMod ALT,R,submap,resize"
        "$mainMod ALT,M,submap,move"
        # Scratchpads
        "$mainMod CTRL, T, exec, pypr toggle term"
        "$mainMod CTRL, V, exec, pypr toggle volume"

        # Pyprland features
        "$mainMod CTRL, M, togglespecialworkspace, minimized"
        "$mainMod, M, exec, pypr toggle_special minimized"
        "$mainMod CTRL, E, exec, pypr expose"
        "$mainMod, Z, exec, pypr zoom"

        # Application launchers
        "$mainMod, RETURN, exec, uwsm app -- ghostty"
        #"$mainMod SHIFT, T, exec, uwsm app -- telegram-desktop"
        "$mainMod SHIFT, B, exec, uwsm app -- qutebrowser"
        "$mainMod, B, exec, uwsm app -- google-chrome-stable"
        "$mainMod, F, exec, uwsm app -- thunar"
        #"$mainMod, S, exec, uwsm app -- spotify"
        #"$mainMod, Y, exec, uwsm app -- youtube-music"
        "$mainMod, D, exec, rofi -show drun"
        #"$mainMod SHIFT, D, exec, firejail --apparmor discord"
        #"$mainMod, ESCAPE, exec, fish -c wlogout_uniqe"
        "$mainMod, ESCAPE, exec, hyprlock"

        # Screenshot and recording
        "$mainMod SHIFT, S, exec, fish -c screenshot_to_clipboard"
        "$mainMod, E, exec, fish -c screenshot_edit"
        "$mainMod SHIFT, R, exec, fish -c record_screen_gif"
        "$mainMod, R, exec, fish -c record_screen_mp4"

        # Clipboard management
        "$mainMod, V, exec, fish -c clipboard_to_type"
        "$mainMod SHIFT, V, exec, fish -c clipboard_to_wlcopy"
        "$mainMod, X, exec, fish -c clipboard_delete_item"
        "$mainMod SHIFT, X, exec, fish -c clipboard_clear"

        # Bookmark management
        "$mainMod, U, exec, fish -c bookmark_to_type"
        "$mainMod SHIFT, U, exec, fish -c bookmark_add"
        "$mainMod CTRL, U, exec, fish -c bookmark_delete"

        # Color picker
        #"$mainMod, C, exec, hyprpicker -a"
        #"$mainMod SHIFT, C, exec, pypr menu \"Color picker\""

        # Window management
        "$mainMod, Q, killactive"
        "$mainMod SHIFT, F, togglefloating"
        "$mainMod CTRL, F, fullscreen, 0"
        "$mainMod SHIFT, P, pseudo" # dwindle
        "$mainMod SHIFT, O, togglesplit" # dwindle
        "$mainMod ALT, M, exit"

        # Moving windows
        "$mainMod SHIFT, left, swapwindow, l"
        "$mainMod SHIFT, right, swapwindow, r"
        "$mainMod SHIFT, up, swapwindow, u"
        "$mainMod SHIFT, down, swapwindow, d"
        "$mainMod SHIFT, h, swapwindow, l"
        "$mainMod SHIFT, l, swapwindow, r"
        "$mainMod SHIFT, k, swapwindow, u"
        "$mainMod SHIFT, j, swapwindow, d"

        # Window resizing
        "$mainMod CTRL, left, resizeactive, -60 0"
        "$mainMod CTRL, right, resizeactive, 60 0"
        "$mainMod CTRL, up, resizeactive, 0 -60"
        "$mainMod CTRL, down, resizeactive, 0 60"
        "$mainMod CTRL, h, resizeactive, -60 0"
        "$mainMod CTRL, l, resizeactive, 60 0"
        "$mainMod CTRL, k, resizeactive, 0 -60"
        "$mainMod CTRL, j, resizeactive, 0 60"

        # System toggles
        "$mainMod SHIFT, A, exec, fish -c airplane_mode_toggle"
        "$mainMod SHIFT, N, exec, dunstctl set-paused toggle"
        #"$mainMod SHIFT, Y, exec, fish -c bluetooth_toggle"
        "$mainMod SHIFT, W, exec, fish -c wifi_toggle"

        # Media controls
        #"$mainMod, p, exec, playerctl play-pause"
        #"$mainMod, bracketright, exec, playerctl next"
        #"$mainMod, bracketleft, exec, playerctl previous"

        # Volume controls
        ", XF86AudioRaiseVolume, exec, volumectl -u up"
        ", XF86AudioLowerVolume, exec, volumectl -u down"
        ", XF86AudioMute, exec, volumectl toggle-mute"
        ", XF86AudioMicMute, exec, volumectl -m toggle-mute"

        # Brightness controls
        ", XF86MonBrightnessUp, exec, lightctl -D intel_backlight up"
        ", XF86MonBrightnessDown, exec, lightctl -D intel_backlight down"

        # Focus movement
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        "$mainMod, Tab, cyclenext,"
        "$mainMod, Tab, bringactivetotop,"

        # Workspace switching - dynamic based on monitor count
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Secondary monitor workspaces
        "$mainMod ALT, 1, workspace, 11"
        "$mainMod ALT, 2, workspace, 12"
        "$mainMod ALT, 3, workspace, 13"
        "$mainMod ALT, 4, workspace, 14"
        "$mainMod ALT, 5, workspace, 15"
        "$mainMod ALT, 6, workspace, 16"
        "$mainMod ALT, 7, workspace, 17"
        "$mainMod ALT, 8, workspace, 18"
        "$mainMod ALT, 9, workspace, 19"
        "$mainMod ALT, 0, workspace, 20"

        # Tertiary monitor workspaces
        "$mainMod CTRL, 1, workspace, 21"
        "$mainMod CTRL, 2, workspace, 22"
        "$mainMod CTRL, 3, workspace, 23"
        "$mainMod CTRL, 4, workspace, 24"
        "$mainMod CTRL, 5, workspace, 25"
        "$mainMod CTRL, 6, workspace, 26"
        "$mainMod CTRL, 7, workspace, 27"
        "$mainMod CTRL, 8, workspace, 28"
        "$mainMod CTRL, 9, workspace, 29"
        "$mainMod CTRL, 0, workspace, 30"

        # Move windows to workspaces - primary monitor
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Move windows to workspaces - secondary monitor
        "$mainMod ALT SHIFT, 1, movetoworkspace, 11"
        "$mainMod ALT SHIFT, 2, movetoworkspace, 12"
        "$mainMod ALT SHIFT, 3, movetoworkspace, 13"
        "$mainMod ALT SHIFT, 4, movetoworkspace, 14"
        "$mainMod ALT SHIFT, 5, movetoworkspace, 15"
        "$mainMod ALT SHIFT, 6, movetoworkspace, 16"
        "$mainMod ALT SHIFT, 7, movetoworkspace, 17"
        "$mainMod ALT SHIFT, 8, movetoworkspace, 18"
        "$mainMod ALT SHIFT, 9, movetoworkspace, 19"
        "$mainMod ALT SHIFT, 0, movetoworkspace, 20"

        # Move windows to workspaces - tertiary monitor
        "$mainMod CTRL SHIFT, 1, movetoworkspace, 21"
        "$mainMod CTRL SHIFT, 2, movetoworkspace, 22"
        "$mainMod CTRL SHIFT, 3, movetoworkspace, 23"
        "$mainMod CTRL SHIFT, 4, movetoworkspace, 24"
        "$mainMod CTRL SHIFT, 5, movetoworkspace, 25"
        "$mainMod CTRL SHIFT, 6, movetoworkspace, 26"
        "$mainMod CTRL SHIFT, 7, movetoworkspace, 27"
        "$mainMod CTRL SHIFT, 8, movetoworkspace, 28"
        "$mainMod CTRL SHIFT, 9, movetoworkspace, 29"
        "$mainMod CTRL SHIFT, 0, movetoworkspace, 30"

        # Workspace scrolling
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      # Window movement/resize with mouse
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  # Additional Hyprland-related packages
  home.packages = with pkgs; [
    pyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    hyprpaper
  ];

  # Configure Hyprlock
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = {
        monitor = "";
        path = "/etc/nixos/assets/wallpaper/wallpaper_3840x2160.jpg";
        blur_passes = 2;
        color = "$base";
      };
      # Time display
      "label" = [
        {
          monitor = "";
          text = "cmd[update:30000] echo \"$(date +\"%I:%M %p\")\"";
          color = "$text";
          font_size = 90;
          font_family = "JetBrains Mono Regular";
          position = "-130, -100";
          halign = "right";
          valign = "top";
          shadow_passes = 2;
        }
        # Date display
        {
          monitor = "";
          text = "cmd[update:43200000] echo \"$(date +\"%A, %d %B %Y\")\"";
          color = "$text";
          font_size = 25;
          font_family = "JetBrains Mono Regular";
          position = "-130, -250";
          halign = "right";
          valign = "top";
          shadow_passes = 2;
        }
        # Keyboard layout
        {
          monitor = "";
          text = "$LAYOUT";
          color = "$text";
          font_size = 20;
          font_family = "JetBrains Mono Regular";
          rotate = 0;
          position = "-130, -310";
          halign = "right";
          valign = "top";
          shadow_passes = 2;
        }
      ];
      # User avatar
      "image" = {
        monitor = "";
        path = "$HOME/.face";
        size = 350;
        border_color = "0xb38bd5ca";
        rounding = -1;
        position = "0, 75";
        halign = "center";
        valign = "center";
        shadow_passes = 2;
      };
      # Input field
      "input-field" = {
        monitor = "";
        size = "400, 70";
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "0xb38bd5ca";
        inner_color = "$surface0";
        font_color = "$text";
        font_size = 20;
        font_family = "JetBrains Mono Regular";
        fade_on_empty = false;
        placeholder_text = "󰌾 <i>Logged in as</i> $USER";
        hide_input = false;
        check_color = "$sky";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, 500";
        halign = "center";
        valign = "bottom";
        shadow_passes = 2;
      };
    };
  };

  # Configure Hypridle
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      "listener" = [
        {
          timeout = 180;
          on-timeout = "brightnessctl -s set 15%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 180;
          on-timeout = "brightnessctl -sd platform::kbd_backlight set 0";
          on-resume = "brightnessctl -rd platform::kbd_backlight";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 350;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 420;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # We're using exec-once to start hyprpaper and pyprland directly
  # No need for systemd services

  # Dynamic wallpaper configuration based on pre-resolved host display configuration
  xdg.configFile."hypr/hyprpaper.conf" = {
    text = let
      primary = primaryDisplayOutput;
      secondary = secondaryDisplayOutput;
      tertiary = tertiaryDisplayOutput;

      # Determine wallpaper orientation based on rotation
      secondaryOrientation = if secondaryRotationSetting == "left"
                             || secondaryRotationSetting == "right"
                             then "vertical" else "horizontal";

      tertiaryOrientation = if tertiaryRotationSetting == "left"
                            || tertiaryRotationSetting == "right"
                            then "vertical" else "horizontal";

      # Select appropriate wallpapers based on orientation
      primaryWallpaper = "/etc/nixos/assets/wallpaper/wallpaper_3840x2160.jpg";
      secondaryWallpaper = if secondaryOrientation == "vertical"
                          then "/etc/nixos/assets/wallpaper/wallpaper_2160x3840.jpg"
                          else "/etc/nixos/assets/wallpaper/wallpaper_3840x2160.jpg";
      tertiaryWallpaper = if tertiaryOrientation == "vertical"
                          then "/etc/nixos/assets/wallpaper/wallpaper_2160x3840.jpg"
                          else "/etc/nixos/assets/wallpaper/wallpaper_3840x2160.jpg";
    in ''
      # Preload all wallpapers
      preload = /etc/nixos/assets/wallpaper/wallpaper_3840x2160.jpg
      preload = /etc/nixos/assets/wallpaper/wallpaper_2160x3840.jpg

      # Assign wallpapers to each monitor
      wallpaper = ${primary},${primaryWallpaper}
      ${if secondary != null then "wallpaper = ${secondary},${secondaryWallpaper}" else ""}
      ${if tertiary != null then "wallpaper = ${tertiary},${tertiaryWallpaper}" else ""}

      ipc = off
      splash = false
    '';
  };
}
