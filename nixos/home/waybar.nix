{pkgs, lib, config, ...}: {
  programs.waybar = {
    enable = true;

    # Use the system-installed Waybar
    package = pkgs.waybar;

    # Ensure waybar starts with systemd
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    
    # Configuration
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;
        
        # Show on primary monitor
        output = ["HDMI-A-1"];

        modules-left = ["hyprland/workspaces"];
        modules-center = [
          "clock#localtime" 
          "custom/separator" 
          "custom/timezone_hk" 
          "custom/timezone_ca" 
          "custom/timezone_ny" 
          "custom/separator" 
          "custom/unixepoch" 
          "custom/separator" 
          "clock#weekday" 
          "clock#date"
        ];
        modules-right = ["group/misc"];
        
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
            "special" = "";
          };
          show-special = true;
          persistent-workspaces = {
            "*" = 10;
          };
        };
        
        "clock#localtime" = {
          format = "{:%H:%M %z}";
          tooltip = false;
        };
        
        "custom/timezone_hk" = {
          exec = "TZ=Asia/Hong_Kong date +'%H HK'";
          interval = 60;
          tooltip = false;
        };
        
        "custom/timezone_ca" = {
          exec = "TZ=America/Los_Angeles date +'%H CA'";
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
        
        "clock#weekday" = {
          format = "{:%a}";
          tooltip = false;
        };
        
        "clock#date" = {
          format = "{:%Y-%m-%d}";
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
            "bluetooth"
          ];
        };
        
        "custom/webcam" = {
          interval = 1;
          exec = "fish -c check_webcam";
          return-type = "json";
        };
        
        privacy = {
          icon-spacing = 1;
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
          interval = 1;
          exec-if = "pgrep wl-screenrec";
          exec = "fish -c check_recording";
          return-type = "json";
        };
        
        "custom/geo" = {
          interval = 1;
          exec-if = "pgrep geoclue";
          exec = "fish -c check_geo_module";
          return-type = "json";
        };
        
        "custom/airplane_mode" = {
          return-type = "json";
          interval = 1;
          exec = "fish -c check_airplane_mode";
          on-click = "fish -c airplane_mode_toggle";
        };
        
        "custom/night_mode" = {
          return-type = "json";
          interval = 1;
          exec = "fish -c check_night_mode";
          on-click = "fish -c night_mode_toggle";
        };
        
        "custom/dunst" = {
          return-type = "json";
          exec = "fish -c dunst_pause";
          on-click = "dunstctl set-paused toggle";
          restart-interval = 1;
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
      };
      
      secondBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        # Only show on second monitor
        output = ["DP-5"];
        
        modules-left = ["hyprland/workspaces"];
        modules-center = [];
        modules-right = [];
        
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
            "special" = "";
          };
          show-special = true;
          persistent-workspaces = {
            "*" = 10;
          };
        };
      };

      bottomBar1 = {
        layer = "top";
        position = "bottom";
        height = 36;
        spacing = 4;
        
        # Only on primary monitor
        output = ["HDMI-A-1"];
        
        modules-left = ["wlr/taskbar" "tray"];
        modules-center = ["hyprland/window"];
        modules-right = ["keyboard-state" "hyprland/language"];
        
        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 20;
          icon-theme = "Numix-Circle";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-right = "close";
          on-click-middle = "fullscreen";
          current-only = true;
          on-scroll-up = "next";
          on-scroll-down = "prev";
          all-outputs = false;
        };
        
        "hyprland/window" = {
          format = "{title}";
          max-length = 100;
          separate-outputs = true;
        };
        
        tray = {
          icon-size = 20;
          spacing = 2;
          show-passive-items = true;
        };
        
        "hyprland/language" = {
          format-en = "ENG (US)";
          format-uk = "UKR";
          format-ru = "RUS";
          keyboard-name = "at-translated-set-2-keyboard";
          on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
        };
        
        "keyboard-state" = {
          capslock = true;
          format = "Caps {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };
      };

      bottomBar2 = {
        layer = "top";
        position = "bottom";
        height = 36;
        spacing = 4;
        
        # Only on secondary monitor
        output = ["DP-5"];
        
        modules-left = ["wlr/taskbar"]; 
        modules-center = ["hyprland/window"];
        modules-right = ["keyboard-state" "hyprland/language"];
        
        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 20;
          icon-theme = "Numix-Circle";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-right = "close";
          on-click-middle = "fullscreen";
          current-only = true;
          on-scroll-up = "next";
          on-scroll-down = "prev";
          all-outputs = false;
        };
        
        "hyprland/window" = {
          format = "{title}";
          max-length = 100;
          separate-outputs = true;
        };
        
        "hyprland/language" = {
          format-en = "ENG (US)";
          format-uk = "UKR";
          format-ru = "RUS";
          keyboard-name = "at-translated-set-2-keyboard";
          on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
        };
        
        "keyboard-state" = {
          capslock = true;
          format = "Caps {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };
      };
    };
    
    # CSS Styles
    style = ''
      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: JetBrainsMono Nerd Font;
      }

      @define-color base   rgba(36, 39, 58, 0);
      @define-color mantle rgba(30, 32, 48, 0);
      @define-color crust  rgba(24, 25, 38, 0);
      
      @define-color text     #cad3f5;
      @define-color subtext0 #a5adcb;
      @define-color subtext1 #b8c0e0;
      
      @define-color surface0 rgba(54, 58, 79, 0.4);
      @define-color surface1 rgba(73, 77, 100, 0.4);
      @define-color surface2 rgba(91, 96, 120, 0.4);
      
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

      /* Override earlier * selector */

      #bottomBar1,
      #bottomBar2 {
        background-color: transparent;
        border-top: solid rgba(73, 77, 100, 0.3) 1px;
      }

      #mainBar, 
      #secondBar {
        background-color: transparent;
        border-bottom: solid rgba(73, 77, 100, 0.3) 1px;
      }
      
      /* Bottom bar */
      #bottomBar1 .modules-left,
      #bottomBar2 .modules-left {
        margin-left: 10;
      }

      #bottomBar1 .modules-center,
      #bottomBar2 .modules-center {
        color: @text;
        margin-top: 3;
        margin-bottom: 3;
      }

      #bottomBar1 .modules-right,
      #bottomBar2 .modules-right {
        margin-right: 10;
      }

      /* Top bar */
      #mainBar .modules-left,
      #secondBar .modules-left {
        margin-left: 10;
      }

      #mainBar .modules-center {
        color: @text;
        margin-top: 3;
        margin-bottom: 3;
      }

      #mainBar .modules-right {
        margin-right: 10;
      }

      /* Keyboard state and language */
      #keyboard-state {
        margin-right: 5;
      }

      #keyboard-state label.locked {
        color: @yellow;
      }

      #keyboard-state label {
        color: @text;
      }

      #language {
        margin-right: 10;
      }

      /* Workspaces */
      #workspaces {
        margin-left: 10;
      }

      #workspaces button {
        color: @text;
        font-size: 1.25rem;
        margin: 0 3px;
      }

      #workspaces button.empty {
        color: @overlay0;
      }

      #workspaces button.active {
        color: @peach;
      }

      /* Clock and time components */
      #clock.localtime {
        color: @text;
      }

      #clock.weekday {
        color: @sapphire;
      }

      #clock.date {
        color: @mauve;
      }

      #custom-unixepoch {
        color: @yellow;
      }

      #custom-timezone_hk,
      #custom-timezone_ca,
      #custom-timezone_ny {
        color: @green;
        margin: 0 3px;
      }

      #custom-separator {
        color: @subtext0;
        margin: 0 5px;
      }

      /* Status icons */
      #bluetooth {
        color: @blue;
        margin: 0 3px;
      }

      #bluetooth.disabled {
        color: @overlay0;
      }

      #bluetooth.connected {
        color: @sapphire;
      }

      #idle_inhibitor {
        margin: 0 3px;
      }

      #idle_inhibitor.deactivated {
        color: @overlay0;
      }

      #custom-dunst.off {
        color: @overlay0;
      }

      #custom-airplane_mode {
        margin: 0 3px;
      }

      #custom-airplane_mode.off {
        color: @overlay0;
      }

      #custom-night_mode {
        margin: 0 3px;
      }

      #custom-night_mode.off {
        color: @overlay0;
      }

      #custom-dunst {
        margin: 0 3px;
      }

      #custom-media.Paused {
        color: @overlay0;
      }

      /* Privacy indicators */
      #custom-webcam {
        color: @maroon;
        margin: 0 3px;
      }

      #privacy-item.screenshare {
        color: @peach;
        margin: 0 3px;
      }

      #privacy-item.audio-in {
        color: @pink;
        margin: 0 3px;
      }

      #custom-recording {
        color: @red;
        margin: 0 3px;
      }

      #custom-geo {
        color: @yellow;
        margin: 0 3px;
      }

      /* Taskbar and Tray */
      #taskbar {
        margin-left: 5;
        margin-right: 5;
      }
      
      #taskbar button {
        margin: 0 2px;
      }
      
      #taskbar button.active {
        background-color: rgba(73, 77, 100, 0.3);
        border-bottom: 2px solid @peach;
      }

      #tray {
        margin-left: 5;
      }

      #tray > .needs-attention {
        background-color: rgba(238, 153, 160, 0.5);
        border-radius: 3px;
      }
    '';
  };
}