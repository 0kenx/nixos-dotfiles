{inputs, pkgs, config, lib, host, ...}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    # Use the same settings as the system configuration
    package = pkgs.hyprland;

    settings = {
      # Use exec-once to set up autostart script
      exec-once = [
        "fish -c autostart"
        "waybar"
        "hyprpaper"
      ];

      # Dynamic monitor configuration from host-specific settings
      monitor = config.nixosConfig.system.nixos-dotfiles.hyprland.monitors or ["eDP-1,preferred,auto,1.6"];

      # Workspace assignment
      workspace = [
        # Main monitor workspaces
        "1,monitor:HDMI-A-1"
        "2,monitor:HDMI-A-1"
        "3,monitor:HDMI-A-1"
        "4,monitor:HDMI-A-1"
        "5,monitor:HDMI-A-1"
        "6,monitor:HDMI-A-1"
        "7,monitor:HDMI-A-1"
        "8,monitor:HDMI-A-1"
        "9,monitor:HDMI-A-1"
        "10,monitor:HDMI-A-1"

        # Secondary monitor workspaces
        "11,monitor:DP-5"
        "12,monitor:DP-5"
        "13,monitor:DP-5"
        "14,monitor:DP-5"
        "15,monitor:DP-5"
        "16,monitor:DP-5"
        "17,monitor:DP-5"
        "18,monitor:DP-5"
        "19,monitor:DP-5"
        "20,monitor:DP-5"
      ];

      # Execute apps at launch
      # Moved to the monitor configuration section above

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
        follow_mouse = 1;
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
        "HYPRCURSOR_THEME,Catppuccin-Macchiato-Teal"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Catppuccin-Macchiato-Teal"
        "XCURSOR_SIZE,24"
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "$teal";
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
          color = "$teal";
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
        workspace_back_and_forth = true;
      };

      # Device settings
      device = [
        {
          name = "epic mouse V1";
          sensitivity = -0.5;
        }
      ];

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
      ];

      # Variable for mod key
      "$mainMod" = "SUPER";

      # Scratchpad variables
      "$dropterm" = "title:^wezterm_dropdown$";
      "$volume_sidemenu" = "title:^Volume Control$";

      # Submaps
 #      submap = {
 #       resize = {
 #          binde = [
 #           ",right,resizeactive,10 0"
 #           ",left,resizeactive,-10 0"
 #            ",up,resizeactive,0 -10"
  #           ",down,resizeactive,0 10"
  #           ",l,resizeactive,10 0"
   #          ",h,resizeactive,-10 0"
  #           ",k,resizeactive,0 -10"
  #           ",j,resizeactive,0 10"
   #        ];
   #        bind = [",escape,submap,reset"];
   #      };
   #      reset = {}; # Reset submap
    #     move = {
   #        bind = [
    #         ",right,movewindow,r"
   #          ",left,movewindow,l"
    #         ",up,movewindow,u"
    #        ",down,movewindow,d"
     #        ",l,movewindow,r"
    #         ",h,movewindow,l"
     #        ",k,movewindow,u"
     #        ",j,movewindow,d"
     #       ",escape,submap,reset"
    #      ];
    #     };
   #    };

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
        "$mainMod, T, exec, ghostty"
        "$mainMod SHIFT, T, exec, telegram-desktop"
        "$mainMod, B, exec, qutebrowser"
        "$mainMod SHIFT, B, exec, brave"
        "$mainMod, F, exec, thunar"
        "$mainMod, S, exec, spotify"
        "$mainMod, Y, exec, youtube-music"
        "$mainMod, D, exec, rofi -show drun"
        "$mainMod SHIFT, D, exec, firejail --apparmor discord"
        "$mainMod, ESCAPE, exec, fish -c wlogout_uniqe"
        "$mainMod SHIFT, L, exec, hyprlock"

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
        "$mainMod, C, exec, hyprpicker -a"
        "$mainMod SHIFT, C, exec, pypr menu \"Color picker\""

        # Window management
        "$mainMod SHIFT, Q, killactive"
        "$mainMod SHIFT, F, togglefloating"
        "$mainMod CTRL, F, fullscreen, 0"
        "$mainMod SHIFT, P, pseudo" # dwindle
        "$mainMod SHIFT, O, togglesplit" # dwindle
        "$mainMod ALT, M, exit"

        # System toggles
        "$mainMod SHIFT, A, exec, fish -c airplane_mode_toggle"
        "$mainMod SHIFT, N, exec, dunstctl set-paused toggle"
        "$mainMod SHIFT, Y, exec, fish -c bluetooth_toggle"
        "$mainMod SHIFT, W, exec, fish -c wifi_toggle"

        # Media controls
        "$mainMod, p, exec, playerctl play-pause"
        "$mainMod, bracketright, exec, playerctl next"
        "$mainMod, bracketleft, exec, playerctl previous"

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

        # Workspace switching (internal monitor)
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

        # Workspace switching (external monitor)
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

        # Move windows to workspaces (internal monitor)
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

        # Move windows to workspaces (external monitor)
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
        path = "$HOME/background";
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
        fade_on_empty = false;
        placeholder_text = "<span foreground=\"##$textAlpha\"><i>󰌾 Logged in as </i><span foreground=\"##8bd5ca\">$USER</span></span>";
        hide_input = false;
        check_color = "$sky";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -185";
        halign = "center";
        valign = "center";
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

  # Configure Hyprpaper with dynamic monitor settings
  xdg.configFile."hypr/hyprpaper.conf" = {
    text = let
      # Base wallpaper path
      wallpaperBase = "/etc/nixos/assets/wallpaper";
      # Default landscape and portrait wallpapers
      landscapeWallpaper = "${wallpaperBase}/wallpaper_3840x2160.jpg";
      portraitWallpaper = "${wallpaperBase}/wallpaper_2160x3840.jpg";

      # Function to generate wallpaper configs for monitors
      monitorWallpaper = monitor:
        let
          monitorParts = lib.strings.splitString "," monitor;
          monitorName = lib.lists.elemAt monitorParts 0;
          # Check if monitor has transform=1 (portrait) in its config
          isPortrait = lib.strings.hasInfix "transform,1" monitor;
          wallpaper = if isPortrait then portraitWallpaper else landscapeWallpaper;
        in
        "wallpaper = ${monitorName},${wallpaper}";

      # Generate wallpaper preloads and assignments
      preloads = ''
        preload = ${landscapeWallpaper}
        preload = ${portraitWallpaper}
      '';

      wallpaperAssignments = lib.strings.concatStringsSep "\n"
        (map monitorWallpaper (config.nixosConfig.system.nixos-dotfiles.hyprland.monitors or ["eDP-1,preferred,auto,1.6"]));
    in
    ''
      ${preloads}

      ${wallpaperAssignments}

      ipc = off
      splash = false
    '';
  };
}
