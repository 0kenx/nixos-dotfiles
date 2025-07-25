{ config, lib, pkgs, resolvedHostDotfilesConfig, ... }:

let
  # Get display configuration from resolved host config
  primaryDisplay = resolvedHostDotfilesConfig.displays.primary or "HDMI-A-1";
  secondaryDisplay = resolvedHostDotfilesConfig.displays.secondary or null;
  
  # Check if we want to map to secondary display (requested is "right" screen)
  # The user wants to map to the right screen, but the workstation config shows
  # the secondary display is vertical and positioned above. We'll need to determine
  # which display is actually on the right at runtime.
  
  # OpenTabletDriver configuration template
  otdConfig = pkgs.writeText "opentabletdriver-config.json" ''
    {
      "Profiles": [
        {
          "Name": "Default",
          "OutputMode": {
            "Path": "OpenTabletDriver.Desktop.Output.AbsoluteMode",
            "Settings": {
              "Display": {
                "Width": 1920.0,
                "Height": 1080.0,
                "X": 0.0,
                "Y": 0.0,
                "Rotation": 0.0
              },
              "Tablet": {
                "Width": 152.0,
                "Height": 95.0,
                "X": 76.0,
                "Y": 47.5,
                "Rotation": 0.0
              },
              "EnableClipping": true,
              "EnableAreaLimiting": false
            }
          }
        }
      ],
      "Bindings": {
        "PenButtons": [
          {
            "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding",
            "Settings": {
              "Button": "Right"
            }
          },
          {
            "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding", 
            "Settings": {
              "Button": "Middle"
            }
          }
        ]
      }
    }
  '';
in
{
  # Enable OpenTabletDriver
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  # Add udev rules for tablet permissions
  services.udev.packages = [ pkgs.opentabletdriver ];

  # Additional packages for tablet configuration
  environment.systemPackages = with pkgs; [
    opentabletdriver
  ];

  # Create systemd service to apply configuration after graphical session starts
  systemd.user.services.opentabletdriver-config = {
    description = "Configure OpenTabletDriver for right monitor";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" "opentabletdriver.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = pkgs.writeShellScript "configure-tablet" ''
        # This script maps the Wacom tablet to the rightmost monitor
        # You can override this by setting WACOM_MONITOR environment variable
        # Example: export WACOM_MONITOR="HDMI-A-1" to map to a specific monitor
        # Wait for OpenTabletDriver to be ready
        for i in {1..10}; do
          if ${pkgs.opentabletdriver}/bin/otd detect; then
            break
          fi
          sleep 1
        done
        
        # Get monitor information from Hyprland if available
        if command -v hyprctl >/dev/null 2>&1; then
          # Check if user specified a monitor
          if [ -n "$WACOM_MONITOR" ]; then
            # Use specified monitor
            MONITOR_INFO=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="'$WACOM_MONITOR'") | "\(.x),\(.y),\(.width),\(.height),\(.name)"')
          else
            # Find the rightmost monitor (highest X position)
            MONITOR_INFO=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r 'max_by(.x) | "\(.x),\(.y),\(.width),\(.height),\(.name)"')
          fi
          
          if [ -n "$MONITOR_INFO" ]; then
            IFS=',' read -r X Y WIDTH HEIGHT MONITOR_NAME <<< "$MONITOR_INFO"
            echo "Mapping tablet to monitor: $MONITOR_NAME at position ($X,$Y)"
            
            # Create dynamic configuration
            cat > ~/.config/OpenTabletDriver/settings.json <<EOF
        {
          "Profiles": [
            {
              "Name": "Default",
              "OutputMode": {
                "Path": "OpenTabletDriver.Desktop.Output.AbsoluteMode",
                "Settings": {
                  "Display": {
                    "Width": $WIDTH,
                    "Height": $HEIGHT,
                    "X": $X,
                    "Y": $Y,
                    "Rotation": 0.0
                  },
                  "Tablet": {
                    "Width": 152.0,
                    "Height": 95.0,
                    "X": 76.0,
                    "Y": 47.5,
                    "Rotation": 0.0
                  },
                  "EnableClipping": true,
                  "EnableAreaLimiting": false
                }
              },
              "Filters": [],
              "PenSettings": {
                "ButtonSettings": [
                  {
                    "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding",
                    "Settings": {
                      "Button": "Right"
                    }
                  },
                  {
                    "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding",
                    "Settings": {
                      "Button": "Middle"
                    }
                  }
                ],
                "PenButtons": [
                  {
                    "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding",
                    "Settings": {
                      "Button": "Right"
                    }
                  },
                  {
                    "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding",
                    "Settings": {
                      "Button": "Middle"
                    }
                  }
                ],
                "AuxButtons": [],
                "TipActivationThreshold": 0.1,
                "TipButton": {
                  "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding",
                  "Settings": {
                    "Button": "Left"
                  }
                }
              }
            }
          ]
        }
EOF
            
            # Restart OpenTabletDriver daemon to apply configuration
            systemctl --user restart opentabletdriver.service
          fi
        else
          # Fallback: Use static configuration for right monitor
          cp ${otdConfig} ~/.config/OpenTabletDriver/settings.json
          systemctl --user restart opentabletdriver.service
        fi
      '';
    };
  };

  # OpenTabletDriver package already includes the GUI tool
  # No need for additional home-manager packages
}