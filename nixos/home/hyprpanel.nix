{pkgs, hostDisplayConfig, ...}: {
  # Enable HyprPanel
  home.packages = with pkgs; [
    hyprpanel
  ];

  # Create HyprPanel configuration directory
  xdg.configFile."hypr/hyprpanel/config.json" = {
    text = ''
      {
        "monitors": {
          "primary": "${hostDisplayConfig.primary}",
          "secondary": "${hostDisplayConfig.secondary or ""}"
        },
        "panel": {
          "position": "top",
          "height": 39,
          "spacing": 4,
          "modules": {
            "left": ["workspaces", "submap"],
            "center": ["clock"],
            "right": ["battery", "network", "bluetooth", "volume", "tray", "notifications"]
          }
        },
        "workspaces": {
          "icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "6": "󰲪",
            "7": "󰲬",
            "8": "󰲮",
            "9": "󰲰",
            "10": "󰿬"
          },
          "persistent_workspaces": {
            "*": 10
          }
        },
        "style": {
          "colorscheme": "catppuccin-macchiato",
          "font": "JetBrains Mono Regular",
          "font_size": 11,
          "transparency": 0.8,
          "border_radius": 10,
          "icon_theme": "Numix-Circle"
        },
        "notifications": {
          "position": "top-right",
          "timeout": {
            "low": 10,
            "normal": 10,
            "critical": 0
          },
          "frame_color": "#cad3f5",
          "background": "#24273A",
          "foreground": "#CAD3F5"
        }
      }
    '';
  };
}