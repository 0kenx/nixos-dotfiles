{pkgs, hostDisplayConfig, ...}: {
  programs.waybar = {
    enable = true;

    # Use the system-installed Waybar
    package = pkgs.waybar;

    # Configuration
    settings = [
      # Secondary Monitor Top Bar (simple layout with workspaces and taskbar)
      {
        name = "secondary_top_bar";
        output = "${hostDisplayConfig.secondary}";
        layer = "top";
        position = "top";
        height = 39;
        spacing = 4;

        modules-left = ["hyprland/workspaces"];
        modules-center = [];
        modules-right = ["wlr/taskbar"];

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "󰲠";
            "2" = "󰲢";
            "3" = "󰲤";
            "4" = "󰲦";
            "5" = "󰲨";
            "6" = "󰲪";
            "7" = "󰲬";
            "8" = "󰲮";
            "9" = "󰲰";
            "10" = "󰿬";
            "11" = "⓫";
            "12" = "⓬";
            "13" = "⓭";
            "14" = "⓮";
            "15" = "⓯";
            "16" = "⓰";
            "17" = "⓱";
            "18" = "⓲";
            "19" = "⓳";
            "20" = "⓴";
            "special" = "";
          };
          show-special = true;
          persistent-workspaces = {
            "*" = 10;
          };
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 20;
          icon-theme = "Numix-Circle";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-right = "close";
          on-click-middle = "fullscreen";
        };
      }

      # Top Bar Config for Primary Monitor
      {
        name = "top_bar";
        output = "${hostDisplayConfig.primary}";
        layer = "top";
        position = "top";
        height = 39;
        spacing = 4;

        modules-left = ["hyprland/workspaces" "hyprland/submap"];
        modules-center = ["clock#time" "custom/separator" "custom/timezone_hk" "custom/separator_dot" "custom/timezone_la" "custom/separator_dot" "custom/timezone_ny" "custom/separator" "custom/unixepoch" "custom/separator" "clock#weekday" "custom/separator_dot" "clock#calendar"];
        modules-right = ["bluetooth" "network" "group/misc" "custom/logout_menu"];

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "󰲠";
            "2" = "󰲢";
            "3" = "󰲤";
            "4" = "󰲦";
            "5" = "󰲨";
            "6" = "󰲪";
            "7" = "󰲬";
            "8" = "󰲮";
            "9" = "󰲰";
            "10" = "󰿬";
            "11" = "⓫";
            "12" = "⓬";
            "13" = "⓭";
            "14" = "⓮";
            "15" = "⓯";
            "16" = "⓰";
            "17" = "⓱";
            "18" = "⓲";
            "19" = "⓳";
            "20" = "⓴";
            "special" = "";
          };
          show-special = true;
          persistent-workspaces = {
            "*" = 10;
          };
        };

        "hyprland/submap" = {
          format = "<span color='#a6da95'>Mode:</span> {}";
          tooltip = false;
        };

        "clock#time" = {
          format = "{:%H:%M %z}";
          tooltip = false;
        };

        "custom/timezone_hk" = {
          exec = "TZ=Asia/Hong_Kong date +'%H HK'";
          interval = 60;
          tooltip = false;
        };

        "custom/timezone_la" = {
          exec = "TZ=America/Los_Angeles date +'%H LA'";
          interval = 60;
          tooltip = false;
        };

        "custom/timezone_ny" = {
          exec = "TZ=America/New_York date +'%H NY'";
          interval = 60;
          tooltip = false;
        };

        "custom/unixepoch" = {
          exec = "date +%s";
          interval = 1;
          tooltip = false;
        };

        "custom/separator" = {
          format = "|";
          tooltip = false;
        };

        "custom/separator_dot" = {
          format = "•";
          tooltip = false;
        };

        "clock#weekday" = {
          format = "{:%a}";
          tooltip = false;
        };

        "clock#month" = {
          format = "{:%h}";
        };

        "clock#calendar" = {
          format = "{:%F}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          actions = {
            on-click-right = "mode";
          };
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#f4dbd6'><b>{}</b></span>";
              days = "<span color='#cad3f5'><b>{}</b></span>";
              weeks = "<span color='#c6a0f6'><b>W{}</b></span>";
              weekdays = "<span color='#a6da95'><b>{}</b></span>";
              today = "<span color='#8bd5ca'><b><u>{}</u></b></span>";
            };
          };
        };

        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_alias} (󰥉 {device_battery_percentage}%)";
          tooltip-format = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected";
          tooltip-format-disabled = "bluetooth off";
          tooltip-format-connected = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t({device_battery_percentage}%)";
          max-length = 35;
          on-click = "fish -c bluetooth_toggle";
          on-click-right = "overskride";
        };

        network = {
          format = "󰤭";
          format-wifi = "{icon} {signalStrength}% {essid}";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          format-disconnected = "󰤫 Disconnected";
          tooltip-format = "wifi <span color='#ee99a0'>off</span>";
          tooltip-format-wifi = "SSID: {essid}({signalStrength}%), {frequency} GHz\nInterface: {ifname}\nIP: {ipaddr}\nGW: {gwaddr}\n\n<span color='#a6da95'>{bandwidthUpBits}</span>\t<span color='#ee99a0'>{bandwidthDownBits}</span>\t<span color='#c6a0f6'>󰹹{bandwidthTotalBits}</span>";
          tooltip-format-disconnected = "<span color='#ed8796'>disconnected</span>";
          max-length = 35;
          on-click = "fish -c wifi_toggle";
          on-click-right = "iwgtk";
        };

        "group/misc" = {
          orientation = "horizontal";
          modules = [
            "custom/webcam"
            "privacy"
            "custom/recording"
            "custom/geo"
            "custom/media"
            "custom/dunst"
            "custom/night_mode"
            "custom/airplane_mode"
            "idle_inhibitor"
          ];
        };

        "custom/webcam" = {
          interval = 5;
          exec = "fish -c check_webcam";
          return-type = "json";
        };

        privacy = {
          icon-spacing = 6;
          icon-size = 12;
          transition-duration = 250;
          modules = [
            {
              type = "audio-in";
            }
            {
              type = "screenshare";
            }
          ];
        };

        "custom/recording" = {
          interval = 3;
          exec-if = "pgrep wl-screenrec";
          exec = "fish -c check_recording";
          return-type = "json";
        };

        "custom/geo" = {
          interval = 10;
          exec-if = "pgrep geoclue";
          exec = "fish -c check_geo_module";
          return-type = "json";
        };

        "custom/airplane_mode" = {
          return-type = "json";
          interval = 5;
          exec = "fish -c check_airplane_mode";
          on-click = "fish -c airplane_mode_toggle";
        };

        "custom/night_mode" = {
          return-type = "json";
          interval = 30;
          exec = "fish -c check_night_mode";
          on-click = "fish -c night_mode_toggle";
        };

        "custom/dunst" = {
          return-type = "json";
          exec = "fish -c dunst_pause";
          on-click = "dunstctl set-paused toggle";
          restart-interval = 3;
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "󰛐";
            deactivated = "󰛑";
          };
          tooltip-format-activated = "idle-inhibitor <span color='#a6da95'>on</span>";
          tooltip-format-deactivated = "idle-inhibitor <span color='#ee99a0'>off</span>";
          start-activated = true;
        };

        "custom/logout_menu" = {
          return-type = "json";
          exec = "echo '{ \"text\":\"󰐥\", \"tooltip\": \"logout menu\" }'";
          interval = "once";
          on-click = "fish -c wlogout_uniqe";
        };
      }

      # Bottom Bar Config for Primary Monitor
      {
        name = "bottom_bar";
        output = "${hostDisplayConfig.primary}";
        layer = "top";
        position = "bottom";
        height = 36;
        spacing = 4;

        modules-left = ["user"];
        modules-center = ["hyprland/window"];
        modules-right = ["keyboard-state" "hyprland/language"];

        "hyprland/window" = {
          format = "{title}";
          max-length = 50;
        };

        "hyprland/language" = {
          format-en = "🇺🇸 EN(US)";
          format-uk = "🇺🇦 UKR";
          format-ru = "🇷🇺 RUS";
          keyboard-name = "at-translated-set-2-keyboard";
          on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
        };

        "keyboard-state" = {
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };

        user = {
          format = " <span color='#8bd5ca'>{user}</span> (up <span color='#f5bde6'>{work_d} d</span> <span color='#8aadf4'>{work_H} h</span> <span color='#eed49f'>{work_M} min</span> <span color='#a6da95'>↑</span>)";
          icon = true;
        };
      }

      # Left Bar Config for Primary Monitor
      {
        name = "left_bar";
        output = "${hostDisplayConfig.primary}";
        layer = "top";
        position = "left";
        spacing = 4;
        width = 45;
        margin-top = 10;
        margin-bottom = 10;

        modules-left = ["wlr/taskbar"];
        modules-center = ["cpu" "memory" "disk" "temperature" "battery" "backlight" "pulseaudio" "systemd-failed-units"];
        modules-right = ["tray"];

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 20;
          icon-theme = "Numix-Circle";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-right = "close";
          on-click-middle = "fullscreen";
        };

        tray = {
          icon-size = 20;
          spacing = 2;
        };

        cpu = {
          format = "󰻠\n{usage}%";
          states = {
            high = 90;
            "upper-medium" = 70;
            medium = 50;
            "lower-medium" = 30;
            low = 10;
          };
          on-click = "ghostty -e btop";
          on-click-right = "ghostty -e btm";
        };

        memory = {
          format = "\n{percentage}%";
          tooltip-format = "Main: ({used} GiB/{total} GiB)({percentage}%), available {avail} GiB\nSwap: ({swapUsed} GiB/{swapTotal} GiB)({swapPercentage}%), available {swapAvail} GiB";
          states = {
            high = 90;
            "upper-medium" = 70;
            medium = 50;
            "lower-medium" = 30;
            low = 10;
          };
          on-click = "ghostty -e btop";
          on-click-right = "ghostty -e btm";
        };

        disk = {
          format = "󰋊\n{percentage_used}%";
          tooltip-format = "({used}/{total})({percentage_used}%) in '{path}', available {free}({percentage_free}%)";
          states = {
            high = 90;
            "upper-medium" = 70;
            medium = 50;
            "lower-medium" = 30;
            low = 10;
          };
          on-click = "ghostty -e btop";
          on-click-right = "ghostty -e btm";
        };

        temperature = {
          tooltip = false;
          "thermal-zone" = 8;
          "critical-threshold" = 80;
          format = "{icon}\n{temperatureC}󰔄";
          "format-critical" = "🔥 {icon}\n{temperatureC}󰔄";
          "format-icons" = ["" "" "" "" ""];
        };

        battery = {
          states = {
            high = 90;
            "upper-medium" = 70;
            medium = 50;
            "lower-medium" = 30;
            low = 10;
          };
          format = "{icon}\n{capacity}%";
          "format-charging" = "󱐋 {icon}\n{capacity}%";
          "format-plugged" = "󰚥 {icon}\n{capacity}%";
          "format-time" = "{H} h {M} min";
          "format-icons" = ["󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          "tooltip-format" = "{timeTo}";
        };

        backlight = {
          format = "{icon}\n{percent}%";
          "format-icons" = [
            "󰌶"
            "󱩎"
            "󱩏"
            "󱩐"
            "󱩑"
            "󱩒"
            "󱩓"
            "󱩔"
            "󱩕"
            "󱩖"
            "󰛨"
          ];
          tooltip = false;
          states = {
            high = 90;
            "upper-medium" = 70;
            medium = 50;
            "lower-medium" = 30;
            low = 10;
          };
          "reverse-scrolling" = true;
          "reverse-mouse-scrolling" = true;
        };

        pulseaudio = {
          states = {
            high = 90;
            "upper-medium" = 70;
            medium = 50;
            "lower-medium" = 30;
            low = 10;
          };
          "tooltip-format" = "{desc}";
          format = "{icon}\n{volume}%\n{format_source}";
          "format-bluetooth" = "󰂱 {icon}\n{volume}%\n{format_source}";
          "format-bluetooth-muted" = "󰂱󰝟\n{volume}%\n{format_source}";
          "format-muted" = "󰝟\n{volume}%\n{format_source}";
          "format-source" = "󰍬\n{volume}%";
          "format-source-muted" = "󰍭\n{volume}%";
          "format-icons" = {
            headphone = "󰋋";
            "hands-free" = "";
            headset = "󰋎";
            phone = "󰄜";
            portable = "󰦧";
            car = "󰄋";
            speaker = "󰓃";
            hdmi = "󰡁";
            hifi = "󰋌";
            default = ["󰕿" "󰖀" "󰕾"];
          };
          "reverse-scrolling" = true;
          "reverse-mouse-scrolling" = true;
          "on-click" = "pavucontrol";
        };

        "systemd-failed-units" = {
          format = "✗\n{nr_failed}";
        };
      }
    ];

    # CSS Styles
    style = ''
      @define-color base   #24273a;
      @define-color mantle #1e2030;
      @define-color crust  #181926;

      /* Secondary monitor bar styles */

      @define-color text     #cad3f5;
      @define-color subtext0 #a5adcb;
      @define-color subtext1 #b8c0e0;

      @define-color surface0 #363a4f;
      @define-color surface1 #494d64;
      @define-color surface2 #5b6078;

      @define-color overlay0 #6e738d;
      @define-color overlay1 #8087a2;
      @define-color overlay2 #939ab7;

      @define-color blue      #8aadf4;
      @define-color lavender  #b7bdf8;
      @define-color sapphire  #7dc4e4;
      @define-color sky       #91d7e3;
      @define-color teal      #8bd5ca;
      @define-color green     #a6da95;
      @define-color yellow    #eed49f;
      @define-color peach     #f5a97f;
      @define-color maroon    #ee99a0;
      @define-color red       #ed8796;
      @define-color mauve     #c6a0f6;
      @define-color pink      #f5bde6;
      @define-color flamingo  #f0c6c6;
      @define-color rosewater #f4dbd6;

      * {
        border: none;
      }

      window.bottom_bar#waybar {
        background-color: alpha(@base, 0.7);
        border-top: solid alpha(@surface1, 0.7) 2;
      }

      window.top_bar#waybar {
        background-color: alpha(@base, 0.7);
        border-bottom: solid alpha(@surface1, 0.7) 2;
      }

      window.left_bar#waybar {
        background-color: alpha(@base, 0.7);
        border-top: solid alpha(@surface1, 0.7) 2;
        border-right: solid alpha(@surface1, 0.7) 2;
        border-bottom: solid alpha(@surface1, 0.7) 2;
        border-radius: 0 15 15 0;
      }

      /* Secondary monitor bar styles */
      window.secondary_top_bar#waybar {
        background-color: alpha(@base, 0.7);
        border-bottom: solid alpha(@surface1, 0.7) 2;
      }

      window.secondary_top_bar .modules-right {
        margin-right: 10;
      }

      window.bottom_bar .modules-center {
        background-color: alpha(@surface1, 0.7);
        color: @green;
        border-radius: 15;
        padding-left: 20;
        padding-right: 20;
        margin-top: 5;
        margin-bottom: 5;
      }

      window.bottom_bar .modules-left {
        background-color: alpha(@surface1, 0.7);
        border-radius: 0 15 15 0;
        padding-left: 20;
        padding-right: 20;
        margin-top: 5;
        margin-bottom: 5;
      }

      window.bottom_bar .modules-right {
        background-color: alpha(@surface1, 0.7);
        border-radius: 15 0 0 15;
        padding-left: 20;
        padding-right: 20;
        margin-top: 5;
        margin-bottom: 5;
      }

      #user {
        padding-left: 10;
      }

      #language {
        padding-left: 15;
      }

      #keyboard-state label.locked {
        color: @yellow;
      }

      #keyboard-state label {
        color: @subtext0;
      }

      #workspaces {
        margin-left: 10;
      }

      #workspaces button {
        color: @text;
        font-size: 1.25rem;
      }

      #workspaces button.empty {
        color: @overlay0;
      }

      #workspaces button.active {
        color: @peach;
      }

      #submap {
        background-color: alpha(@surface1, 0.7);
        border-radius: 15;
        padding-left: 15;
        padding-right: 15;
        margin-left: 20;
        margin-right: 20;
        margin-top: 5;
        margin-bottom: 5;
      }

      window.top_bar .modules-center {
        font-weight: bold;
        background-color: alpha(@surface1, 0.7);
        color: @peach;
        border-radius: 15;
        padding-left: 20;
        padding-right: 20;
        margin-top: 5;
        margin-bottom: 9;
      }

      #custom-separator {
        color: @green;
      }

      #custom-separator_dot {
        color: @green;
      }

      #clock.time {
        color: @flamingo;
      }

      #clock.unixepoch {
        color: @flamingo;
      }

      #clock.weekday {
        color: @sapphire;
      }

      #clock.month {
        color: @sapphire;
      }

      #clock.calendar {
        color: @mauve;
      }

      #bluetooth {
        background-color: alpha(@surface1, 0.7);
        border-radius: 15;
        padding-left: 15;
        padding-right: 15;
        margin-top: 5;
        margin-bottom: 9;
      }

      #bluetooth.disabled {
        background-color: alpha(@surface0, 0.7);
        color: @subtext0;
      }

      #bluetooth.on {
        color: @blue;
      }

      #bluetooth.connected {
        color: @sapphire;
      }

      #network {
        background-color: alpha(@surface1, 0.7);
        border-radius: 15;
        padding-left: 15;
        padding-right: 15;
        margin-left: 2;
        margin-right: 2;
        margin-top: 5;
        margin-bottom: 9;
      }

      #network.disabled {
        background-color: alpha(@surface0, 0.7);
        color: @subtext0;
      }

      #network.disconnected {
        color: @red;
      }

      #network.wifi {
        color: @sapphire;
      }

      #idle_inhibitor {
        margin-right: 15;
      }

      #idle_inhibitor.deactivated {
        color: @subtext0;
      }

      #custom-dunst.off {
        color: @subtext0;
      }

      #custom-airplane_mode {
        margin-right: 15;
      }

      #custom-airplane_mode.off {
        color: @subtext0;
      }

      #custom-night_mode {
        margin-right: 15;
      }

      #custom-night_mode.off {
        color: @subtext0;
      }

      #custom-dunst {
        margin-right: 15;
      }

      #custom-media.Paused {
        color: @subtext0;
      }

      #custom-webcam {
        color: @maroon;
        margin-right: 15;
      }

      #privacy-item.screenshare {
        color: @peach;
        margin-right: 15;
      }

      #privacy-item.audio-in {
        color: @pink;
        margin-right: 15;
      }

      #custom-recording {
        color: @red;
        margin-right: 15;
      }

      #custom-geo {
        color: @yellow;
        margin-right: 15;
      }

      #custom-logout_menu {
        color: @red;
        background-color: alpha(@surface1, 0.7);
        border-radius: 15 0 0 15;
        padding-left: 15;
        padding-right: 15;
        margin-top: 5;
        margin-bottom: 9;
      }

      window.left_bar .modules-center {
        background-color: alpha(@surface1, 0.7);
        border-radius: 0 15 15 0;
        margin-right: 5;
        margin-top: 15;
        margin-bottom: 15;
        padding-top: 15;
        padding-bottom: 15;
      }

      #taskbar {
        margin-top: 10;
        margin-right: 10;
        margin-left: 10;
      }

      #taskbar button.active {
        background-color: alpha(@surface1, 0.7);
        border-radius: 10;
      }

      #tray {
        margin-bottom: 30;
        margin-right: 10;
        margin-left: 10;
      }

      #tray>.needs-attention {
        background-color: alpha(@maroon, 0.7);
        border-radius: 10;
      }

      #cpu {
        color: @sapphire;
      }

      #cpu.low {
        color: @rosewater;
      }

      #cpu.lower-medium {
        color: @yellow;
      }

      #cpu.medium {
        color: @peach;
      }

      #cpu.upper-medium {
        color: @maroon;
      }

      #cpu.high {
        color: @red;
      }

      #memory {
        color: @sapphire;
      }

      #memory.low {
        color: @rosewater;
      }

      #memory.lower-medium {
        color: @yellow;
      }

      #memory.medium {
        color: @peach;
      }

      #memory.upper-medium {
        color: @maroon;
      }

      #memory.high {
        color: @red;
      }

      #disk {
        color: @sapphire;
      }

      #disk.low {
        color: @rosewater;
      }

      #disk.lower-medium {
        color: @yellow;
      }

      #disk.medium {
        color: @peach;
      }

      #disk.upper-medium {
        color: @maroon;
      }

      #disk.high {
        color: @red;
      }

      #temperature {
        color: @green;
      }

      #temperature.critical {
        color: @red;
      }

      #battery {
        color: @sapphire;
      }

      #battery.low {
        color: @red;
      }

      #battery.lower-medium {
        color: @maroon;
      }

      #battery.medium {
        color: @peach;
      }

      #battery.upper-medium {
        color: @flamingo;
      }

      #battery.high {
        color: @rosewater;
      }

      #backlight {
        color: @overlay0;
      }

      #backlight.low {
        color: @overlay1;
      }

      #backlight.lower-medium {
        color: @overlay2;
      }

      #backlight.medium {
        color: @subtext0;
      }

      #backlight.upper-medium {
        color: @subtext1;
      }

      #backlight.high {
        color: @text;
      }

      #pulseaudio.bluetooth {
        color: @sapphire;
      }

      #pulseaudio.muted {
        color: @surface2;
      }

      #pulseaudio {
        color: @text;
      }

      #pulseaudio.low {
        color: @overlay0;
      }

      #pulseaudio.lower-medium {
        color: @overlay1;
      }

      #pulseaudio.medium {
        color: @overlay2;
      }

      #pulseaudio.upper-medium {
        color: @subtext0;
      }

      #pulseaudio.high {
        color: @subtext1;
      }

      #systemd-failed-units {
        color: @red;
      }
    '';
  };
}
